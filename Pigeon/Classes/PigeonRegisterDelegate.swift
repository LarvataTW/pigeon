//
//  PigeonRegisterDelegate.swift
//  Pigeon
//
//  Created by Larvata on 2018/9/11.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
public protocol PigeonRegisterDelegate: class {

  func pigeonPresentationOptions() -> UNNotificationPresentationOptions
  func pigeonNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Swift.Void)
  func pigeonNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void)

}

@available(iOS 10.0, *)
extension PigeonRegisterDelegate {

  public func pigeonPresentationOptions() -> UNNotificationPresentationOptions {
    return [.alert, .badge, .sound]
  }

  public func pigeonNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
    completionHandler()
  }

  public func pigeonNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
    completionHandler(pigeonPresentationOptions())
  }

}

/**
 如果協定對象有同時遵守 UIApplicationDelegate 協議（白話： 如果從AppDelegate）
 */
@available(iOS 10.0, *)
extension PigeonRegisterDelegate where Self: UIApplicationDelegate {
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // 註冊裝置
    PigeonService.registerDeviceToken(deviceToken: deviceToken)
  }
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    // 註冊失敗
    fatalError("do something...?")
  }
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    // 收到推播
  }
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // 收到推播
  }
}
