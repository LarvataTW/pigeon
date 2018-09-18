//
//  PigeonService.swift
//  Pigeon
//
//  Created by Larvata on 2018/9/11.
//

import Foundation
import UserNotifications

public class PigeonService: NSObject {

  public private(set) static var pigeonToken: String?
  private(set) static var appKey: String?
  private(set) static var deviceToken: String?

  private static var pigeonService: PigeonService?

  @available(iOS 10.0, *)
  private(set) static var delegate: PigeonRegisterDelegate?

  @available(iOS 10.0, *)
  public static func registerForRemoteNotifications(appKey: String, delegate: PigeonRegisterDelegate) {
    self.appKey = appKey
    self.delegate = delegate

    self.pigeonService = PigeonService()

    requestNotificationsPermission {
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

  public static func registerDeviceToken(deviceToken: Data) {
    self.deviceToken = deviceToken.reduce("") {
      $0 + String(format: "%02x", $1)
    }

    fatalError("Must Implement")
  }

  private static func requestNotificationsPermission(completion: @escaping () -> Swift.Void) {
    if #available(iOS 10.0, *) {
      let options: UNAuthorizationOptions = [.alert, .sound, .badge]
      UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
        if granted {
          UNUserNotificationCenter.current().delegate = self.pigeonService
          completion()
        }
      }
    }
  }

  /**
   Send request to server to register new device.

   - parameter device: Registered device.
   - parameter onCompleted: Action to invoke upon server returned successful response.
   - parameter onError: Action to invoke upon server returned unexpected response or request timeout.
   */
  private static func register(device: Device, onCompleted: @escaping (Device) -> Void, onError: @escaping (Error) -> Void) {
    fatalError("Must Implement")
  }

}

@available(iOS 10.0, *)
extension PigeonService: UNUserNotificationCenterDelegate {

  public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     didReceive response: UNNotificationResponse,
                                     withCompletionHandler completionHandler: @escaping () -> Void) {
    PigeonService.delegate?.pigeonNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    PigeonService.delegate?.pigeonNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }

}
