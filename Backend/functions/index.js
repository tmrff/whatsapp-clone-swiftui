require("dotenv").config
const functions = require('firebase-functions/v1');

const admin = require("firebase-admin");

const { StreamChat } = require("stream-chat")

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

// Stream Client

const apiKey = process.env.API_KEY;
const apiSecret = process.env.API_SECRET;
const streamClient = StreamChat.getInstance(apiKey, apiSecret);

export const createStreamUser = functions.auth.user()
.onCreate(async(user) => {
    logger.log("Firebase user was created", user);
    const response = await streamClient.upsertUser({
        id: user.uid,
        name: user.displayName,
        email: user.email,
        image: user.photoURL
    })
    
    logger.log("Stream user was created", response);
    return response;
});
