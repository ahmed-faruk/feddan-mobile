import * as admin from "firebase-admin";
import { fetchWeather, WeatherData } from "./nasaPower";
import {
  CropType, CROP_NAME_AR, getKc, isFertilizationDay,
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

export async function runDailyTaskEngine(
  db: admin.firestore.Firestore,
): Promise<void> {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const scheduledTs = admin.firestore.Timestamp.fromDate(today);
  const now = admin.firestore.Timestamp.now();

  const farmsSnap = await db.collection("farms").get();
  if (farmsSnap.empty) {
    console.log("[TaskEngine] No farms — nothing to do.");
    return;
  }

  let totalTasks = 0;

  for (const farmDoc of farmsSnap.docs) {
    const farm = farmDoc.data() as FarmDoc;
    if (!farm.latitude || !farm.longitude || !farm.cropTypes?.length) continue;

    let weather: WeatherData;
    try {
      weather = await fetchWeather(farm.latitude, farm.longitude, today);
    } catch (err) {
      console.error(`[${farmDoc.id}] Weather fetch failed:`, err);
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
      const kc = getKc(cropType, daysSincePlanting);
      const etc = weather.et0 * kc;
      const cropAr = CROP_NAME_AR[cropType];

      // ── Irrigation ────────────────────────────────────────────────────────
      if (weather.rainfall >= RAIN_SKIP_THRESHOLD_MM) {
        farmTasks.push({
          farmId: farmDoc.id, cropType, type: "IRRIGATE_SKIP",
          priority: "LOW", scheduledDate: scheduledTs,
          messageAr: `ري ${cropAr} غير مطلوب — متوقع هطول ${weather.rainfall.toFixed(0)} مم`,
          messageEn: `${cropType} irrigation skipped — ${weather.rainfall.toFixed(0)}mm rain expected`,
          status: "PENDING", waterDemandMm: etc, createdAt: now,
        });
      } else if (etc >= IRRIGATE_THRESHOLD_MM) {
        farmTasks.push({
          farmId: farmDoc.id, cropType, type: "IRRIGATE",
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
          farmId: farmDoc.id, cropType, type: "INSPECT",
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
          farmId: farmDoc.id, cropType, type: "FERTILIZE",
          priority: "NORMAL", scheduledDate: scheduledTs,
          messageAr: `ضع السماد الأساسي لـ${cropAr} عند الزراعة`,
          messageEn: `Apply base fertilizer for ${cropType} at planting`,
          status: "PENDING", createdAt: now,
        });
      } else if (fertType === "nitrogen") {
        farmTasks.push({
          farmId: farmDoc.id, cropType, type: "FERTILIZE",
          priority: "NORMAL", scheduledDate: scheduledTs,
          messageAr: `سماد نيتروجيني لـ${cropAr} — بداية مرحلة النمو`,
          messageEn: `Nitrogen fertilizer for ${cropType} — growth stage started`,
          status: "PENDING", createdAt: now,
        });
      } else if (fertType === "potassium") {
        farmTasks.push({
          farmId: farmDoc.id, cropType, type: "FERTILIZE",
          priority: "HIGH", scheduledDate: scheduledTs,
          messageAr: `سماد بوتاسيوم وفوسفور لـ${cropAr} — مرحلة التزهير`,
          messageEn: `K+P fertilizer for ${cropType} — flowering stage`,
          status: "PENDING", createdAt: now,
        });
      }
    }

    // Write tasks in a batch
    if (farmTasks.length > 0) {
      const batch = db.batch();
      for (const task of farmTasks) {
        const ref = db.collection("farms").doc(farmDoc.id)
          .collection("tasks").doc();
        batch.set(ref, task);
      }
      await batch.commit();
      totalTasks += farmTasks.length;

      // Send FCM digest for high-priority tasks
      const highTasks = farmTasks.filter((t) => t.priority === "HIGH");
      if (highTasks.length > 0) {
        await sendDailyDigest(
          db,
          farm.ownerId,
          farm.name ?? "مزرعتك",
          highTasks.map((t) => ({ messageAr: t.messageAr, messageEn: t.messageEn, type: t.type })),
        );
      }
    }
  }

  console.log(
    `[TaskEngine] Done — ${totalTasks} tasks across ${farmsSnap.size} farms.`,
  );
}
