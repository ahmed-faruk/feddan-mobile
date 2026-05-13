import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { runDailyTaskEngine } from "./taskEngine";
import { runWeatherAlerts } from "./weatherAlerts";

admin.initializeApp();

// C1: 540s timeout (max for 1st-gen) + 512MB memory so serial weather fetches
// across many farms don't hit the 60s default and get killed mid-run.
const LONG_RUNNING = { timeoutSeconds: 540, memory: "512MB" } as const;

/**
 * Daily task engine — runs at 06:00 Cairo time (Africa/Cairo = UTC+2/+3).
 * Fetches NASA POWER weather for each farm and writes irrigation,
 * fertilization, and inspection tasks to Firestore.
 *
 * Requires Firebase Blaze plan for Cloud Scheduler.
 */
export const dailyTaskEngine = functions
  .runWith(LONG_RUNNING)
  .pubsub
  .schedule("0 6 * * *")
  .timeZone("Africa/Cairo")
  .onRun(async (_context) => {
    await runDailyTaskEngine(admin.firestore());
    return null;
  });

// Weather alert scanner — runs every 6 hours, checks OWM for extreme conditions.
// Requires OWM_API_KEY secret: firebase functions:secrets:set OWM_API_KEY
export const weatherAlerts = functions
  .runWith(LONG_RUNNING)
  .pubsub
  .schedule("0 */6 * * *")
  .timeZone("Africa/Cairo")
  .onRun(async () => {
    await runWeatherAlerts(admin.firestore());
    return null;
  });

// Manual trigger for testing. Requires Authorization: Bearer <ADMIN_SECRET> header.
// Set ADMIN_SECRET via: firebase functions:secrets:set ADMIN_SECRET
export const runTaskEngineNow = functions
  .runWith(LONG_RUNNING)
  .https.onRequest(async (req, res) => {
  const secret = process.env.ADMIN_SECRET;
  if (!secret || req.headers.authorization !== `Bearer ${secret}`) {
    res.status(403).json({ error: "Forbidden" });
    return;
  }
  try {
    await runDailyTaskEngine(admin.firestore());
    res.json({ success: true, message: "Task engine completed" });
  } catch (err) {
    console.error("Task engine error:", err);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
  });
