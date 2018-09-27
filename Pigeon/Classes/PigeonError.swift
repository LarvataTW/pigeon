//
//  PigeonError.swift
//  Pigeon
//
//  Created by Larvata on 2018/9/26.
//

import Foundation

let unexpectedError = -1

private var pigeonErrorDescription: [Int: String] = [
  -1: "unexpected error",
  202: "less parameter",
  204: "app doesn't register",
  400: "pigeon token is wrong",
  401: "without pigeon token"
]

public struct PigeonServiceError: Error {
  var localizedDescription: String {
    return pigeonErrorDescription[statusCode] ?? "unexpected error"
  }

  private(set) var statusCode: Int

  init(statusCode: Int) {
    self.statusCode = statusCode
  }
}
