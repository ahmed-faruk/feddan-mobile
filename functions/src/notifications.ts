import * as admin from "firebase-admin";

interface HighTask {
  messageAr: string;
  messageEn: string;
  type: string;
}

/**
 * Sends a daily digest push notification to the farm owner.
 * Called by the task engine after processing a farm.
 * Silently skips if no FCM token is stored.
 */
export async function sendDailyDigest(
  db: admin.firestore.Firestore,
  ownerId: string,
  farmName: string,
  highTasks: HighTask[],
): Promise<void> {
  if (highTasks.length === 0) return;

  const userSnap = await db.collection("users").doc(ownerId).get();
  const fcmToken = userSnap.data()?.fcmToken as string | undefined;
  if (!fcmToken) return;

  // Build Arabic body — up to 3 tasks, dot-separated
  const bodyAr = highTasks
    .slice(0, 3)
    .map((t) => t.messageAr)
    .join(" • ");

  const bodyEn = highTasks
    .slice(0, 3)
    .map((t) => t.messageEn)
    .join(" • ");

  const taskCountLabel = highTasks.length > 1
    ? `${highTasks.length} مهام مهمة`
    : "مهمة مهمة";

  try {
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: `فدان — ${farmName} — ${taskCountLabel}`,
        body: bodyAr,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "feddan_tasks",
          priority: "high",
          defaultSound: true,
          localOnly: false,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: highTasks.length,
            alert: {
              title: `فدان — ${farmName}`,
              body: bodyAr,
            },
          },
        },
      },
      data: {
        type: "daily_tasks",
        farmName,
        taskCount: String(highTasks.length),
        bodyEn,
      },
    });
    console.log(`[FCM] Sent digest to ${ownerId} — ${highTasks.length} high-priority tasks`);
  } catch (err: unknown) {
    // Stale token (messaging/registration-token-not-registered) — remove it
    if (
      typeof err === "object" &&
      err !== null &&
      "code" in err &&
      (err as { code: string }).code === "messaging/registration-token-not-registered"
    ) {
      await db.collection("users").doc(ownerId).update({ fcmToken: admin.firestore.FieldValue.delete() });
      console.warn(`[FCM] Removed stale token for ${ownerId}`);
    } else {
      console.error(`[FCM] Send failed for ${ownerId}:`, err);
    }
  }
}
