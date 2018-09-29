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
  static func validateStatusCode(_ code: Int) throws {
    let codeType = statusType(code)
    if codeType != StatusCodeType.success,
       let error = serviceError(codeType: codeType) {
      throw error
    }
  }

  static func serviceError(codeType: StatusCodeType) -> PigeonServiceError? {
    switch codeType {
    case .unexpectedError,
         .appNotExist,
         .lessParameter,
         .noPigeonToken,
         .pigeonTokenWrong:
      return PigeonServiceError.unexpectedError(NSError(domain: NSURLErrorDomain,
                                                        code: codeType.rawValue,
                                                        userInfo: nil))
    case .success:
      return nil
    }
  }

  private static func statusType(_ code: Int) -> StatusCodeType {
    return StatusCodeType(rawValue: code) ?? StatusCodeType.unexpectedError
  }
}
