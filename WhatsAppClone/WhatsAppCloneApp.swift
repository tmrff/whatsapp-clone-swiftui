//
//  WhatsAppCloneApp.swift
//  WhatsAppClone
//
//  Created by Thomas on 7/06/24.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        setupPushNotifications(for: application)
        return true
    }
  
    private func setupPushNotifications(for application: UIApplication) {
        let notificationCenter = UNUserNotificationCenter.current()
        Messaging.messaging().delegate = self
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
      
        notificationCenter.requestAuthorization(options: options) { granted, error in
            if let error {
                print("APNS Failed to request authorization: \(error.localizedDescription)")
                return
            }
          
            if granted {
                print("APNS authorization granted")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
              print("APNS authorization denied")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
  
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("APNS firebase device token: \(String(describing: fcmToken))")
    }
  
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS successfully registered with device token: \(deviceToken)")
    }
  
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .banner, .badge]
    }
}


@main
struct WhatsAppCloneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            RootScreen()
        }
    }
}
