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
