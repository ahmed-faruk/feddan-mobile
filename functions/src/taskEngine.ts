import * as admin from "firebase-admin";
import { fetchWeather, WeatherData } from "./nasaPower";
import {
  CropType, CROP_NAME_AR, getKc, isFertilizationDay, STAGE_DAYS,
} from "./cropConstants";
import { sendDailyDigest } from "./notifications";

type TaskType = "IRRIGATE" | "IRRIGATE_SKIP" | "FERTILIZE" | "INSPECT";
type Priority = "HIGH" | "NORMAL" | "LOW";

interface FarmDoc {
  name: string;
  latitude: number;
  longitude: number;
  cropTypes: CropType[];
  plantingDate: admin.firestore.Timestamp;
  ownerId: string;
}

interface TaskDoc {
  farmId: string;
  cropType: string;
  ownerId: string; // denormalised for Firestore rules — avoids get() cost per task read
  type: TaskType;
  priority: Priority;
  scheduledDate: admin.firestore.Timestamp;
  messageAr: string;
  messageEn: string;
  status: "PENDING";
  waterDemandMm?: number;
  createdAt: admin.firestore.Timestamp;
}

const IRRIGATE_THRESHOLD_MM = 3.0;
const RAIN_SKIP_THRESHOLD_MM = 3.0;

// C2: Deterministic doc-ID key — same farm + date + crop + type always maps
// to the same Firestore path, so a double-fired scheduler writes nothing new.
function toDateKey(d: Date): string {
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}${pad(d.getMonth() + 1)}${pad(d.getDate())}`;
}

export async function runDailyTaskEngine(
  db: admin.firestore.Firestore,
): Promise<void> {
  // Compute today's date in Cairo local time so the scheduledDate boundary
  // matches the farmer's calendar regardless of UTC offset (UTC+2/+3 DST).
  const cairoMidnight = new Date(
    new Date().toLocaleString("en-US", { timeZone: "Africa/Cairo" }),
  );
  cairoMidnight.setHours(0, 0, 0, 0);
  const today = cairoMidnight;
  const scheduledTs = admin.firestore.Timestamp.fromDate(today);
  const now = admin.firestore.Timestamp.now();
  // C2: pre-compute once; used to build deterministic document IDs.
  const dateKey = toDateKey(today);

  const farmsSnap = await db.collection("farms").get();
  if (farmsSnap.empty) {
    console.log("[TaskEngine] No farms — nothing to do.");
    return;
  }

  let totalTasks = 0;

  for (const farmDoc of farmsSnap.docs) {
  try {
    const farm = farmDoc.data() as FarmDoc;
    if (!farm.latitude || !farm.longitude || !farm.cropTypes?.length) continue;

    // C2: Idempotency guard — if the scheduler fires twice today, the first run
    // already wrote tasks; skip the farm to avoid overwriting user-set statuses.
    const existingToday = await db
      .collection("farms").doc(farmDoc.id)
      .collection("tasks")
      .where("scheduledDate", "==", scheduledTs)
      .limit(1)
      .get();
    if (!existingToday.empty) {
      console.log(`[TaskEngine] Farm ${farmDoc.id} already has tasks for today — skipping (idempotency guard).`);
      continue;
    }

    let weather: WeatherData;
    try {
      weather = await fetchWeather(farm.latitude, farm.longitude, today);
    } catch (err) {
      console.error(`[${farmDoc.id}] Weather fetch failed:`, err);
      continue;
    }

    // M5: If NASA POWER returned -999 for all parameters, safeAvg() gives 0
    // across the board. ET0=0, maxTemp=0, humidity=0 cannot occur on a real
    // day in Egypt — treat this as a bad-data signal and skip task generation.
    if (weather.et0 === 0 && weather.maxTempC === 0 && weather.humidityPct === 0) {
      console.warn(
        `[TaskEngine] Farm ${farmDoc.id}: all weather values are zero — ` +
        `NASA POWER likely returned -999 fill-values. Skipping task generation to avoid bad data.`,
      );
      continue;
    }

    const plantingDate = farm.plantingDate
      ? farm.plantingDate.toDate()
      : new Date(today.getTime() - 30 * 86_400_000);

    const daysSincePlanting = Math.floor(
      (today.getTime() - plantingDate.getTime()) / 86_400_000,
    );

    const farmTasks: TaskDoc[] = [];

    for (const cropType of farm.cropTypes) {
      // M6: Skip crops whose full growth cycle has already ended, or whose
      // planting date is in the future (user data entry error). Past-cycle
      // farms would keep generating IRRIGATE tasks indefinitely at late-stage Kc.
      const totalCycleDays = STAGE_DAYS[cropType].reduce((s, d) => s + d, 0);
      if (daysSincePlanting < 0 || daysSincePlanting > totalCycleDays) {
        console.log(
          `[TaskEngine] Farm ${farmDoc.id}, ${cropType}: ` +
          `daysSincePlanting=${daysSincePlanting} is outside [0, ${totalCycleDays}] — skipping crop.`,
        );
        continue;
      }

      const kc = getKc(cropType, daysSincePlanting);
      const etc = weather.et0 * kc;
      const cropAr = CROP_NAME_AR[cropType];

      // ── Irrigation ────────────────────────────────────────────────────────
      if (weather.rainfall >= RAIN_SKIP_THRESHOLD_MM) {
        farmTasks.push({
          farmId: farmDoc.id, cropType, ownerId: farm.ownerId, type: "IRRIGATE_SKIP",
          priority: "LOW", scheduledDate: scheduledTs,
          messageAr: `ري ${cropAr} غير مطلوب — متوقع هطول ${weather.rainfall.toFixed(0)} مم`,
          messageEn: `${cropType} irrigation skipped — ${weather.rainfall.toFixed(0)}mm rain expected`,
          status: "PENDING", waterDemandMm: etc, createdAt: now,
        });
      } else if (etc >= IRRIGATE_THRESHOLD_MM) {
        farmTasks.push({
          farmId: farmDoc.id, cropType, ownerId: farm.ownerId, type: "IRRIGATE",
          priority: etc >= 6.0 ? "HIGH" : "NORMAL",
          scheduledDate: scheduledTs,
          messageAr: `ري ${cropAr} اليوم — الطلب المائي ${etc.toFixed(1)} مم`,
          messageEn: `Irrigate ${cropType} today — ${etc.toFixed(1)}mm demand`,
          status: "PENDING", waterDemandMm: etc, createdAt: now,
        });
      }

      // ── Disease / Inspection ──────────────────────────────────────────────
      if (weather.humidityPct > 80 && weather.maxTempC > 15 && weather.maxTempC < 30) {
        farmTasks.push({
          farmId: farmDoc.id, cropType, ownerId: farm.ownerId, type: "INSPECT",
          priority: "NORMAL", scheduledDate: scheduledTs,
          messageAr: `تفقد ${cropAr} — رطوبة ${weather.humidityPct.toFixed(0)}٪، خطر فطري`,
          messageEn: `Inspect ${cropType} — ${weather.humidityPct.toFixed(0)}% humidity, fungal risk`,
          status: "PENDING", createdAt: now,
        });
      }

      // ── Fertilization ─────────────────────────────────────────────────────
      const fertType = isFertilizationDay(cropType, daysSincePlanting);
      if (fertType === "base") {
        farmTasks.push({
          farmId: farmDoc.id, cropType, ownerId: farm.ownerId, type: "FERTILIZE",
          priority: "NORMAL", scheduledDate: scheduledTs,
          messageAr: `ضع السماد الأساسي لـ${cropAr} عند الزراعة`,
          messageEn: `Apply base fertilizer for ${cropType} at planting`,
          status: "PENDING", createdAt: now,
        });
      } else if (fertType === "nitrogen") {
        farmTasks.push({
          farmId: farmDoc.id, cropType, ownerId: farm.ownerId, type: "FERTILIZE",
          priority: "NORMAL", scheduledDate: scheduledTs,
          messageAr: `سماد نيتروجيني لـ${cropAr} — بداية مرحلة النمو`,
          messageEn: `Nitrogen fertilizer for ${cropType} — growth stage started`,
          status: "PENDING", createdAt: now,
        });
      } else if (fertType === "potassium") {
        farmTasks.push({
          farmId: farmDoc.id, cropType, ownerId: farm.ownerId, type: "FERTILIZE",
          priority: "HIGH", scheduledDate: scheduledTs,
          messageAr: `سماد بوتاسيوم وفوسفور لـ${cropAr} — مرحلة التزهير`,
          messageEn: `K+P fertilizer for ${cropType} — flowering stage`,
          status: "PENDING", createdAt: now,
        });
      }
    }

    // Persist today's weather snapshot onto the farm document so the Flutter
    // app can display it without a separate Firestore read.
    try {
      await db.collection("farms").doc(farmDoc.id).update({
        latestWeather: {
          date: scheduledTs,
          et0: weather.et0,
          rainfall: weather.rainfall,
          maxTempC: weather.maxTempC,
          minTempC: weather.minTempC,
          humidityPct: weather.humidityPct,
        },
      });
    } catch (err) {
      console.error(`[Weather] Failed to update farm ${farmDoc.id}:`, err);
    }

    // Write tasks in a batch
    // C2: deterministic doc ID = farmId_YYYYMMDD_cropType_taskType.
    // (IRRIGATE/IRRIGATE_SKIP/FERTILIZE/INSPECT are mutually exclusive per
    // crop per day, so this combination is always unique within a farm.)
    // The existence guard above is the primary idempotency mechanism; the
    // deterministic ID is the belt-and-suspenders fallback.
    if (farmTasks.length > 0) {
      const batch = db.batch();
      for (const task of farmTasks) {
        const docId = `${farmDoc.id}_${dateKey}_${task.cropType}_${task.type}`;
        const ref = db.collection("farms").doc(farmDoc.id)
          .collection("tasks").doc(docId);
        batch.set(ref, task);
      }
      await batch.commit();
      totalTasks += farmTasks.length;

      // Send FCM digest for high-priority tasks
      const highTasks = farmTasks.filter((t) => t.priority === "HIGH");
      if (highTasks.length > 0) {
        try {
          await sendDailyDigest(
            db,
            farm.ownerId,
            farm.name ?? "مزرعتك",
            highTasks.map((t) => ({ messageAr: t.messageAr, messageEn: t.messageEn, type: t.type })),
          );
        } catch (err) {
          // FCM failure must not fail the whole function — tasks are already written
          console.error(`[FCM] Digest failed for farm ${farmDoc.id}:`, err);
        }
      }
    }
  } catch (err) {
    console.error(`[TaskEngine] Farm ${farmDoc.id} failed — skipping:`, err);
  }

  console.log(
    `[TaskEngine] Done — ${totalTasks} tasks across ${farmsSnap.size} farms.`,
  );
}
