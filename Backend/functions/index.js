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

// Listen for new messages in a channel
exports.listenForNewMessages = functions.database
.ref(channelMessageRef)
.onCreate(async (snapshot, context) => {
	const data = snapshot.val()
	const channelId = context.params.channelId
	const message = data["text"]
	const ownerUid = data["ownerUid"]
	
	// Get the message sender name
	const messageSenderSnapshot = await admin
		.database()	
		.ref("/users/" + ownerUid)
		.once("value")

		const messageSenderDict = messageSenderSnapshot.val()
		const senderName = messageSenderDict["username"]
		await getChannelMembers(channelId, message, senderName)
})

// Get channel members
async function getChannelMembers(channelId, message, senderName) {
	const channelSnapshot = await admin
	.database()
	.ref("/channels/" + channelId)
	.once("value")
	
	const channelDict = channelSnapshot.val()
	const memberUids = channelDict["membersUids"]
	
	for (const userId of memberUids) {
		await getUserFcmToken(message, userId, senderName)
	}
}

// Get the fcm token for each channel member
async function getUserFcmToken(message, userId, senderName) {
	const userSnapshot = await admin
	.database()
	.ref("/users/" + userId)
	.once("value")

	const userDict = userSnapshot.val()
	const fcmToken = userDict["fcmToken"]
	await sendPushNotification(message, senderName, fcmToken)
}

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
