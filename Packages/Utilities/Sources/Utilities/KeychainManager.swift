//
//  KeychainManager.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 09.09.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import Foundation
import LibraryCore

@objc
public class KeychainManager: NSObject, KeychainProvider {

    public func add(password: String, to account: String) throws {
        deletePassword(of: account)
        let accountData = account.data(using: .utf8)!
        let identifierData = password.data(using: .utf8)!
        let addquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: accountData,
                                       kSecValueData as String: identifierData]

        let status = SecItemAdd(addquery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: "com.elbedev.sync.KeychainManager", code: 1) }
    }

    public func password(for account: String) -> String? {
        let accountData = account.data(using: .utf8)!
        let getquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: accountData,
                                       kSecReturnData as String: kCFBooleanTrue as Any,
                                       kSecMatchLimit as String: kSecMatchLimitOne]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else {
            let err = NSError(domain: "com.elbedev.sync.KeychainManager", code: 2)
            print(err)
            return nil
        }
        guard let x = item as? Data,
            let identifier = String(data:x, encoding: .utf8) else {
                return nil
        }

        return identifier
    }

    public func deletePassword(of account: String) {
        let query = [
            kSecClass       : kSecClassGenericPassword,
            kSecAttrAccount : account
        ] as [CFString : Any] as CFDictionary

        SecItemDelete(query)
    }
}
