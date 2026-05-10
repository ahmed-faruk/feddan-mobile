import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { runDailyTaskEngine } from "./taskEngine";

admin.initializeApp();

/**
 * Daily task engine — runs at 06:00 Cairo time (Africa/Cairo = UTC+2/+3).
 * Fetches NASA POWER weather for each farm and writes irrigation,
 * fertilization, and inspection tasks to Firestore.
 *
 * Requires Firebase Blaze plan for Cloud Scheduler.
 */
export const dailyTaskEngine = functions.pubsub
  .schedule("0 6 * * *")
  .timeZone("Africa/Cairo")
  .onRun(async (_context) => {
    await runDailyTaskEngine(admin.firestore());
    return null;
  });

/**
 * HTTP trigger for manual testing — remove before production.
 * Call: POST https://<region>-feddan-mobile.cloudfunctions.net/runTaskEngineNow
 */
export const runTaskEngineNow = functions.https.onRequest(async (_req, res) => {
  try {
    await runDailyTaskEngine(admin.firestore());
    res.json({ success: true, message: "Task engine completed" });
  } catch (err) {
    console.error("Task engine error:", err);
    res.status(500).json({ success: false, error: String(err) });
  }
});
