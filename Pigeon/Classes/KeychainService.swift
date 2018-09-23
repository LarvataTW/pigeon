//
//  KeychainService.swift
//  Pigeon
//
//  Created by Larvata on 2018/9/22.
//

import UIKit
import Security

enum KeychainError: Error {
  case noToken
  case unexpectedTokenData
  case unexpectedItemData
  case unhandledError(status: OSStatus)
}

struct KeychainService {

  private let service: String

  init(service: String) {
    self.service = service
  }

  func read(account: String) throws -> String {
    var query = keychainQuery(service: service, account: account)
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    query[kSecReturnAttributes as String] =  true
    query[kSecReturnData as String] = true

    var queryResult: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &queryResult)
    guard status != errSecItemNotFound else { throw KeychainError.noToken }
    guard status == noErr else { throw KeychainError.unhandledError(status: status) }

    guard let existingItem = queryResult as? [String : AnyObject],
             let tokenData = existingItem[kSecValueData as String] as? Data,
             let token = String(data: tokenData, encoding: String.Encoding.utf8)
      else {
        throw KeychainError.unexpectedTokenData
    }

    return token
  }

  func save(account: String, token: String) throws {
    do {
      try _ = read(account: account)

      // update
      var updateAttr = [String: Any]()
      updateAttr[kSecValueData as String] = token.data(using: String.Encoding.utf8)!

      let query = keychainQuery(service: service, account: account)
      let status = SecItemUpdate(query as CFDictionary, updateAttr as CFDictionary)
      guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }

    } catch KeychainError.noToken {
      // add
      var query = keychainQuery(service: service, account: account)
      query[kSecValueData as String] = token.data(using: String.Encoding.utf8)!

      let status = SecItemAdd(query as CFDictionary, nil)
      guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
  }

  private func keychainQuery(service: String, account: String) -> [String: Any] {
    var query =  [String: Any]()
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrService as String] = service
    query[kSecAttrAccount as String] = account
    return query
  }
}
