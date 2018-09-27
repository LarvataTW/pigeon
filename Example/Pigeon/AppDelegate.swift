//
//  AppDelegate.swift
//  Pigeon
//
//  Created by Larvata on 09/06/2018.
//  Copyright (c) 2018 Larvata. All rights reserved.
//

import UIKit
import Pigeon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    //    var systemInfo = utsname()
    //    uname(&systemInfo)
    //    let machineMirror = Mirror(reflecting: systemInfo.machine)
    //    let identifier = machineMirror.children.reduce("") { identifier, element in
    //      guard let value = element.value as? Int8, value != 0 else { return identifier }
    //      return identifier + String(UnicodeScalar(UInt8(value)))
    //    }
    //    print(identifier)

    // 假設我一開始就要註冊推播
    if #available(iOS 10.0, *) {
      PigeonService.shared.registerForRemoteNotifications(appKey: "appKey", delegate: self)
    } else {
      // Fallback on earlier versions
    }

    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // 註冊裝置
    if #available(iOS 10.0, *) {
      PigeonService.shared.registerDeviceToken(deviceToken: deviceToken)
    }
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

extension AppDelegate: PigeonRegisterDelegate {
  func pigeonNotificationCenter(didReceive error: Error) {
    print("pigeonNotificationCenter didReceive error: \(error)")
  }
}
