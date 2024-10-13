const functions = require('firebase-functions/v1');

const admin = require("firebase-admin");

admin.initializeApp();

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// exports.helloWorld = onRequest((request, response) => {
// 	logger.info("Hello logs!", {structuredData: true});
// 	response.send("Hello from Firebase!");
// });

const channelMessageRef = "/channel-messages/{channelId}/{messageId}"

exports.sendNotificationsForMessages = functions.database
.ref(channelMessageRef)
.onCreate(async (snapshot, context) => {
    const data = snapshot.val()
    const message = data.text
    const senderName = data.channelNameAtSend
    const chatParticipantFCMTokens = data.chatParticipantFCMTokens
    
    for (const fcmToken of chatParticipantFCMTokens) {
        await sendPushNotification(message, senderName, fcmToken)
    }
})

// Send push notification from cloud functions using apns
async function sendPushNotification(message, senderName, fcmToken) {
	const payload = {
		notification: {
			title: senderName,
			body: message,
		},

		apns: {
			payload: {
				aps: {
					sound: "default",
					badge: 5,
				}
			}
		},
		
		token: fcmToken,
	};

	try {
		await admin.messaging().send(payload);
		console.info("Successfully sent message: ", message)
	} catch (error) {
		console.error("Error sending message: ", error)
	}
}
