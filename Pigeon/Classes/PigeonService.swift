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
  private let keychain: KeychainService

  struct KeychainConfigure {
    static let service = "PigeonService.com"
    static let PigeonTokenAccount = "PigeonToken"
    static let DeviceTokenAccount = "DeviceToken"
  }

  public override init() {
    apiService = APIService()
    keychain = KeychainService(service: KeychainConfigure.service)
    super.init()
  }

  /**
   Send request to APNs server to get device token.

   - parameter appKey: Each app have own key when create a new application.
   - parameter delegate: Who follow PigeonRegisterDelegate protocol.
   */
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

  /**
   start register new device.

   - parameter deviceToken: Devicetoken from application:didRegisterForRemoteNotificationsWithDeviceToken:.
   */
  public func registerDeviceToken(deviceToken: Data) {
    self.deviceToken = deviceToken.reduce("") {
      $0 + String(format: "%02x", $1)
    }

    var device = Device()
    device.deviceModel = UIDevice.current.model
    device.deviceToken = self.deviceToken
    device.active = true
    device.appKey = self.appKey
    device.pigeonToken = try? keychain.read(account: KeychainConfigure.PigeonTokenAccount)

    register(device: device, onCompleted: { [unowned self] (device) in
      self.savePigeonToken(device)
    }, onError: { [unowned self] (error) in
      self.delegate?.pigeonNotificationCenter(didReceive: error)
    })
  }

  private func requestNotificationsPermission(completion: @escaping () -> Swift.Void) {
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, _) in
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
  private func register(device: Device, onCompleted: @escaping (Device) -> Void, onError: @escaping (PigeonServiceError) -> Void) {

    if device.pigeonToken != nil {
      apiService.patchDevice(device, completionHandler: {[unowned self] (data) in
        let device = self.device(from: data)
        onCompleted(device)
      }, errorHandler: { (error) in
        onError(error)
      })
    } else {
      apiService.registerDevice(device, completionHandler: {[unowned self] (data) in
        let device = self.device(from: data)
        onCompleted(device)
      }, errorHandler: { (error) in
        onError(error)
      })
    }
  }

  private func device(from data: Data) -> Device {
    var device = Device()
    guard let json = try? JSONSerialization.jsonObject(with: data, options: [])  else { return device}
    guard let dict = json as? [String: Any] else { return device}

    device.deviceModel = dict["device_model"] as? String
    device.active = dict["active"] as? Bool
    device.pigeonToken = dict["pigeon_token"] as? String
    device.deviceToken = dict["device_token"] as? String

    return device
  }

  private func savePigeonToken(_ device: Device) {
    guard let token = device.pigeonToken else { return }
    try? keychain.save(account: KeychainConfigure.PigeonTokenAccount, token: token)
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
