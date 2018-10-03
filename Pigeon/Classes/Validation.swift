//
//  Validation.swift
//  Pigeon
//
//  Created by Larvata on 2018/9/29.
//

import Foundation

// Status Code List
enum StatusCodeType: Int {
  case unexpectedError = -1
  case success = 200
  case lessParameter = 202
  case appNotExist = 204
  case pigeonTokenWrong = 400
  case noPigeonToken = 401
}

extension StatusCodeType: Equatable {
  public static func == (lhs: StatusCodeType, rhs: StatusCodeType) -> Bool {
    switch (lhs, rhs) {
    case (.success, .success):
      return true
    default:
      return false
    }
  }
}

//
class Validation: NSObject {
  static func validateResponse(_ response: HTTPURLResponse) throws {
    let codeType = statusType(response.statusCode)
    if codeType != StatusCodeType.success,
       let error = serviceError(codeType: codeType) {
      throw error
    }
  }

  static func serviceError(codeType: StatusCodeType) -> PigeonServiceError? {
    switch codeType {
    case .unexpectedError:
      return PigeonServiceError.unexpectedError(NSError(domain: "pigeon service error domain",
                                                        code: codeType.rawValue,
                                                        userInfo: nil))
    case.appNotExist:
      return PigeonServiceError.invalidAppKey
    case .noPigeonToken:
      return PigeonServiceError.validateError(code: codeType.rawValue, detail: "pigeon token is missing.")
    case .pigeonTokenWrong:
      return PigeonServiceError.validateError(code: codeType.rawValue, detail: "pigeon token is invalid.")
    case .lessParameter:
      // TODO: fix params value later
      return PigeonServiceError.parameterError(params: nil)
    case .success:
      return nil
    }
  }

  static func validateAppKey(_ appKey: String?) throws {
    guard let key = appKey else {
      throw PigeonServiceError.invalidAppKey
    }

    guard !key.isEmpty else {
      throw PigeonServiceError.invalidAppKey
    }
  }

  private static func statusType(_ code: Int) -> StatusCodeType {
    return StatusCodeType(rawValue: code) ?? StatusCodeType.unexpectedError
  }
}
