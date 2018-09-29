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
  case parameterError(Error)
  case appkeyError(Error)
  case pigeonTokenError(Error)
}

extension PigeonServiceError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .networkFail(let err):
      return err.localizedDescription
    case .unexpectedError:
      return "unexpected error"
    case .parameterError:
      return "less parameter"
    case .appkeyError:
      return "app doesn't register"
    case .pigeonTokenError:
      return "pigeon token is wrong"
    }
  }
}
