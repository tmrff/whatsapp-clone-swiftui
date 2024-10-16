const functions = require('firebase-functions/v1');

const admin = require("firebase-admin");

admin.initializeApp();

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const channelMessageRef = "/channel-messages/{channelId}/{messageId}"

exports.sendNotificationsForMessages = functions.database
.ref(channelMessageRef)
.onCreate(async (snapshot, context) => {
    const data = snapshot.val()
    const textMessage = data.text
    const senderName = data.channelNameAtSend
    const chatParticipantFCMTokens = data.chatParticipantFCMTokens
    const messageType = data.type
    
    let notificationMessage = textMessage
    
    if (messageType === "photo") {
        notificationMessage = "Send a Photo Message"
    } else if (messageType === "video") {
        notificationMessage = "Send a Video Message"
    } else if (messageType === "audio") {
        notificationMessage = "Send a Voice Message"
    }

    for (const fcmToken of chatParticipantFCMTokens) {
        await sendPushNotification(notificationMessage, senderName, fcmToken)
    }
})

exports.sendMessageReactionNotification = functions.https.onCall(
    (async (data, context) => {
        const fcmToken = data.fcmToken
        const channelNameAtSend = data.channelNameAtSend
        const notificationMessage = data.notificationMessage
        
        await sendPushNotification(notificationMessage, channelNameAtSend, fcmToken)
    }
))

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
