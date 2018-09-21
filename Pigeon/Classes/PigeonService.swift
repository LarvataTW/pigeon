//
//  PigeonService.swift
//  Pigeon
//
//  Created by Larvata on 2018/9/11.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
public class PigeonService: NSObject {

  public static let shared = PigeonService()

  public private(set) var pigeonToken: String?
  private(set) var appKey: String?
  private(set) var deviceToken: String?

  private(set) weak var delegate: PigeonRegisterDelegate?

  private let apiService: APIService

  public override init() {
    apiService = APIService()
    super.init()
  }

  @available(iOS 10.0, *)
  public func registerForRemoteNotifications(appKey: String, delegate: PigeonRegisterDelegate) {
    self.appKey = appKey
    self.delegate = delegate

    requestNotificationsPermission {
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

  public func registerDeviceToken(deviceToken: Data) {
    self.deviceToken = deviceToken.reduce("") {
      $0 + String(format: "%02x", $1)
    }

    print("deviceToken : \(self.deviceToken)")

    var device = Device()
    device.deviceModel = UIDevice.current.model
    device.deviceToken = self.deviceToken
    device.active = true
    device.appKey = self.appKey

    register(device: device, onCompleted: { (device) in
      print(device)
    }) { (error) in
      print("register error: \(error)")
    }
  }

  private func requestNotificationsPermission(completion: @escaping () -> Swift.Void) {
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
      if granted {
        UNUserNotificationCenter.current().delegate = self
        completion()
      }
    }
  }

  /**
   Send request to server to register new device.

   - parameter device: Registered device.
   - parameter onCompleted: Action to invoke upon server returned successful response.
   - parameter onError: Action to invoke upon server returned unexpected response or request timeout.
   */
  private func register(device: Device, onCompleted: @escaping (Device) -> Void, onError: @escaping (Error) -> Void) {
    apiService.registerDevice(device, completionHandler: {[unowned self] (data) in
      let device = self.deviceFrom(data)
      onCompleted(device)
    }) { (error) in
      onError(error)
    }
  }

  private func deviceFrom(_ data: Data) -> Device {
    var device = Device()
    guard let json = try? JSONSerialization.jsonObject(with: data, options: [])  else { return device}
    guard let dict = json as? Dictionary<String, Any> else { return device}
    print("response: \(dict)")

    device.deviceModel = dict["device_model"] as? String
    device.active = dict["active"] as? Bool
    device.pigeonToken = dict["pigeon_token"] as? String
    device.deviceToken = dict["device_token"] as? String

    return device
  }

}

@available(iOS 10.0, *)
extension PigeonService: UNUserNotificationCenterDelegate {

  public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     didReceive response: UNNotificationResponse,
                                     withCompletionHandler completionHandler: @escaping () -> Void) {
    delegate?.pigeonNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    delegate?.pigeonNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }
}
