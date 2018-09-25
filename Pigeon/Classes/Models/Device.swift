//
//  DeviceType.swift
//  Pigeon
//
//  Created by Larvata on 2018/9/14.
//

import Foundation

public struct Device: Codable {

  public var deviceToken: String?
  public var deviceModel: String?
  public var active: Bool?
  public var pigeonToken: String?
  public var appKey: String?
}

extension Device {
  func body() -> [String: Any] {
    return ["device_token": deviceToken ?? "",
            "device_model": deviceModel ?? "",
            "active": active ?? true,
            "pigeonToken": pigeonToken ?? ""]
  }
}
