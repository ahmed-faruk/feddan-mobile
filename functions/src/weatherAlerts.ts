import * as admin from "firebase-admin";
import axios from "axios";

const OWM_BASE = "https://api.openweathermap.org/data/2.5/weather";

// Alert thresholds tuned for Egyptian/MENA agriculture
const HEAT_C = 42;      // heat-stress threshold
const FROST_C = 5;      // frost-risk threshold
const RAIN_MM_1H = 8;   // heavy rain per hour (unusual in Egypt — stop irrigation)

interface OWMResponse {
  main: { temp: number; humidity: number };
  rain?: { "1h"?: number };
  weather: Array<{ main: string }>;
}

interface Alert {
  titleAr: string;
  bodyAr: string;
  titleEn: string;
  bodyEn: string;
  severity: "HIGH" | "NORMAL";
}

function detectAlerts(w: OWMResponse): Alert[] {
  const alerts: Alert[] = [];
  const temp = w.main.temp;
  const rain = w.rain?.["1h"] ?? 0;
  const condition = w.weather[0]?.main ?? "";

  if (temp >= HEAT_C) {
    alerts.push({
      titleAr: "تحذير: موجة حر",
      bodyAr: `درجة الحرارة ${temp.toFixed(0)}°م — حماية المحاصيل ضرورية`,
      titleEn: "Warning: Heat Wave",
      bodyEn: `Temperature ${temp.toFixed(0)}°C — protect your crops`,
      severity: "HIGH",
    });
  }

  if (temp <= FROST_C) {
    alerts.push({
      titleAr: "تحذير: خطر الصقيع",
      bodyAr: `درجة الحرارة ${temp.toFixed(0)}°م — تأمين المحاصيل الحساسة`,
      titleEn: "Warning: Frost Risk",
      bodyEn: `Temperature ${temp.toFixed(0)}°C — protect sensitive crops`,
      severity: "HIGH",
    });
  }

  if (rain >= RAIN_MM_1H) {
    alerts.push({
      titleAr: "تنبيه: هطول مطر غزير",
      bodyAr: `${rain.toFixed(0)} مم/ساعة — أوقف الري`,
      titleEn: "Alert: Heavy Rain",
      bodyEn: `${rain.toFixed(0)}mm/h — suspend irrigation`,
      severity: "NORMAL",
    });
  }

  if (condition === "Dust" || condition === "Sand" || condition === "Squall") {
    alerts.push({
      titleAr: "تنبيه: عاصفة ترابية",
      bodyAr: "عاصفة ترابية — أمّن محاصيلك",
      titleEn: "Alert: Dust Storm",
      bodyEn: "Dust storm expected — protect your crops",
      severity: "HIGH",
    });
  }

  return alerts;
}

// OWM grid resolution is ~1°, so we round lat/lon to 1 decimal place to
// deduplicate API calls for farms in the same region. This keeps usage well
// within the 1,000 calls/day free tier even at scale.
function gridKey(lat: number, lon: number): string {
  return `${lat.toFixed(1)}_${lon.toFixed(1)}`;
}

export async function runWeatherAlerts(
  db: admin.firestore.Firestore,
): Promise<void> {
  const apiKey = process.env.OWM_API_KEY;
  if (!apiKey) {
    console.warn("[WeatherAlerts] OWM_API_KEY secret not set — skipping run");
    return;
  }

  const farmsSnap = await db.collection("farms").get();
  if (farmsSnap.empty) return;

  // Step 1: Deduplicate OWM calls by ~1° grid cell.
  // Farms within the same cell share weather — one API call covers all of them.
  const gridCache = new Map<string, OWMResponse | null>();

  // Collect unique owner IDs to batch-fetch FCM tokens in one pass.
  const ownerIds = new Set<string>();
  for (const farmDoc of farmsSnap.docs) {
    const ownerId = farmDoc.data().ownerId as string | undefined;
    if (ownerId) ownerIds.add(ownerId);
  }

  // Step 2: Fetch FCM tokens for all unique owners up front (avoids N+1 Firestore reads).
  const tokenMap = new Map<string, string>();
  await Promise.all([...ownerIds].map(async (uid) => {
    const snap = await db.collection("users").doc(uid).get();
    const token = snap.data()?.fcmToken as string | undefined;
    if (token) tokenMap.set(uid, token);
  }));

  for (const farmDoc of farmsSnap.docs) {
    const farm = farmDoc.data();
    if (!farm.latitude || !farm.longitude || !farm.ownerId) continue;

    const key = gridKey(farm.latitude as number, farm.longitude as number);

    // Fetch weather for this grid cell only if not already cached this run.
    if (!gridCache.has(key)) {
      try {
        const { data } = await axios.get<OWMResponse>(OWM_BASE, {
          params: {
            lat: (farm.latitude as number).toFixed(1),
            lon: (farm.longitude as number).toFixed(1),
            appid: apiKey,
            units: "metric",
          },
          timeout: 10_000,
        });
        gridCache.set(key, data);
      } catch (err) {
        console.error(`[WeatherAlerts] OWM fetch failed for grid ${key}:`, err);
        gridCache.set(key, null); // mark as failed so we don't retry this cell
      }
    }

    const weather = gridCache.get(key);
    if (!weather) continue;

    const alerts = detectAlerts(weather);
    if (alerts.length === 0) continue;

    const fcmToken = tokenMap.get(farm.ownerId as string);
    if (!fcmToken) continue;

    for (const alert of alerts) {
      try {
        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title: `فدان — ${(farm.name as string) ?? "مزرعتك"} — ${alert.titleAr}`,
            body: alert.bodyAr,
          },
          android: {
            priority: "high",
            notification: {
              channelId: "feddan_tasks",
              priority: alert.severity === "HIGH" ? "high" : "default",
              defaultSound: true,
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                alert: {
                  title: `فدان — ${(farm.name as string) ?? "مزرعتك"}`,
                  body: alert.bodyAr,
                },
              },
            },
          },
          data: {
            type: "weather_alert",
            titleEn: alert.titleEn,
            bodyEn: alert.bodyEn,
            severity: alert.severity,
            farmId: farmDoc.id,
          },
        });
        console.log(`[WeatherAlerts] ${alert.titleEn} → farm ${farmDoc.id} (grid ${key})`);
      } catch (err) {
        console.error(`[WeatherAlerts] FCM failed for farm ${farmDoc.id}:`, err);
      }
    }
  }
}
