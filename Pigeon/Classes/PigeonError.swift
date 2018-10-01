//
//  PigeonError.swift
//  Pigeon
//
//  Created by Larvata on 2018/9/26.
//

import Foundation

public enum PigeonServiceError: Error {
  case networkFail(Error)
  case unexpectedError(Error)
  case invalidAppKey
  case parameterError(params: [String: String]?)
  case validateError(code: Int, detail: String?)
}

extension PigeonServiceError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .networkFail(let err):
      return err.localizedDescription
    case .unexpectedError:
      return "unexpected error"
    case .invalidAppKey:
      return "app key is invalid"
    case .parameterError:
      return "less parameter"
    case .validateError(let code, let detail):
      return "errorCode(\(code)) \(detail ?? "")"
    }
  }
}
