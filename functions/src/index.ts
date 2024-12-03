/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize the Firebase Admin SDK
admin.initializeApp();

const db = admin.firestore();

// Cloud Function to fetch tasks from the last 2 days
exports.fetchTasksFromLastTwoDays = functions.https.onCall(async (data, context) => {
  const userId = data.userId;

  if (!userId) {
    throw new functions.https.HttpsError('invalid-argument', 'User ID is required');
  }

  try {
    // Get the current time
    const now = new Date();

    // Calculate the start of the 2-day range
    const twoDaysAgo = new Date();
    twoDaysAgo.setDate(now.getDate() - 2);

    // Query Firestore to get tasks within the last 2 days
    const tasksQuerySnapshot = await db
      .collection('DailyItems')
      .where('userId', '==', userId)
      .where('startDateTime', '>=', admin.firestore.Timestamp.fromDate(twoDaysAgo))
      .where('startDateTime', '<=', admin.firestore.Timestamp.fromDate(now))
      .orderBy('startDateTime', 'desc')
      .get();

    // Convert the query snapshot to a list of task maps
    const recentTasks = tasksQuerySnapshot.docs.map(doc => doc.data());

    // Return the list of tasks
    return { recentTasks };

  } catch (error) {
    console.error('Error fetching tasks:', error);
    throw new functions.https.HttpsError('internal', 'Error fetching tasks');
  }
});
