//
//  NSError+DomainSpecific.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 04/10/15.
//  Copyright © 2015 neoneon. All rights reserved.
//

import Foundation

public extension NSError {
    
    enum Codes: Int {
        case unknownErrorCode = 0
        case missingUserIdErrorCode
        case missingPasswordErrorCode
        case authenticationFailureErrorCode
        case requestFailureErrorCode
    }
    
    static func authenticationError() -> NSError {
        let domain = "com.elbedev.sync"
        let localizedDescription = NSLocalizedString("AUTHENTICATION_FAILED", tableName: "Applicationwide", bundle: Bundle.main, value: "Authentication failed", comment: "Incorrect credentials message")
        let localizedFailureReason = NSLocalizedString("AUTHENTICATION_FAILED_ADVICE", tableName: "Applicationwide", bundle: Bundle.main, value: "Please check your username, password and the selected library.", comment: "Incorrect credentials message")
        return NSError(domain: domain, code: 3, userInfo: [NSLocalizedDescriptionKey : localizedDescription,
            NSLocalizedFailureReasonErrorKey : localizedFailureReason])
    }

    static var accountNotFoundError: Error {
        let domain = "com.elbedev.sync"
        let localizedDescription = NSLocalizedString("AUTHENTICATION_FAILED_NO_ACCOUNT", tableName: "Applicationwide", bundle: Bundle.main, value: "Authentication failed", comment: "The account could not be retrieved from storage")
        let localizedFailureReason = NSLocalizedString("NOT_ACTIVATED_DUE_TO_MISSING_CREDENTIALS", tableName: "Applicationwide", bundle: Bundle.main, value: "Please enter your username and password.", comment: "Missing username and password message")
        return NSError(domain: domain, code: 5, userInfo: [NSLocalizedDescriptionKey : localizedDescription,
                                                    NSLocalizedFailureReasonErrorKey : localizedFailureReason])
    }

   static func missingCredentialsError() -> NSError {
        let domain = "com.elbedev.sync"
        let localizedDescription = NSLocalizedString("AUTHENTICATION_FAILED", tableName: "Applicationwide", bundle: Bundle.main, value: "Authentication failed", comment: "Incorrect credentials message")
        let localizedFailureReason = NSLocalizedString("NOT_ACTIVATED_DUE_TO_MISSING_CREDENTIALS", tableName: "Applicationwide", bundle: Bundle.main, value: "Please enter your username and password.", comment: "Missing username and password message")
        return NSError(domain: domain, code: 5, userInfo: [NSLocalizedDescriptionKey : localizedDescription,
                                                           NSLocalizedFailureReasonErrorKey : localizedFailureReason])
    }
    
    static func missingUserIDError() -> NSError {
        let domain = "com.elbedev.sync"
        let localizedDescription = NSLocalizedString("AUTHENTICATION_FAILED", tableName: "Applicationwide", bundle: Bundle.main, value: "Authentication failed", comment: "Incorrect credentials message")
        let localizedFailureReason = NSLocalizedString("NOT_ACTIVATED_DUE_TO_MISSING_USERID", tableName: "Applicationwide", bundle: Bundle.main, value: "Please enter your username.", comment: "Missing username message")
        return NSError(domain: domain, code: 1, userInfo: [NSLocalizedDescriptionKey : localizedDescription,
            NSLocalizedFailureReasonErrorKey : localizedFailureReason])
    }
    
    static func missingPasswordError() -> NSError {
        let domain = "com.elbedev.sync"
        let localizedDescription = NSLocalizedString("AUTHENTICATION_FAILED", tableName: "Applicationwide", bundle: Bundle.main, value: "Authentication failed", comment: "Incorrect credentials message")
        let localizedFailureReason = NSLocalizedString("NOT_ACTIVATED_DUE_TO_MISSING_PASSWORD", tableName: "Applicationwide", bundle: Bundle.main, value: "Please enter your password.", comment: "Missing password message")
        return NSError(domain: domain, code: 2, userInfo: [NSLocalizedDescriptionKey : localizedDescription,
            NSLocalizedFailureReasonErrorKey : localizedFailureReason])
    }

    static func unknownLibraryError() -> NSError {
        let domain = "com.elbedev.sync"
        let localizedDescription = NSLocalizedString("The action could not be performed because the library is unknown.", tableName: "Applicationwide", bundle: Bundle.main, value: "The action could not be performed because the library is unknown.", comment: "The action could not be performed because the library is unknown.")
        let localizedFailureReason = NSLocalizedString("Please use a library known to the application.", tableName: "Applicationwide", bundle: Bundle.main, value: "Please use a library known to the application.", comment: "Please use a library known to the application.")
        return NSError(domain: domain, code: 2, userInfo: [NSLocalizedDescriptionKey : localizedDescription,
                                                           NSLocalizedFailureReasonErrorKey : localizedFailureReason])
    }
    
    static func requestError() -> NSError {
        let domain = "com.elbedev.sync"
        let localizedDescription = NSLocalizedString("ERROR", tableName: "Applicationwide", bundle: Bundle.main, value: "An error occurred", comment: "Error occurred message")
        let localizedFailureReason = NSLocalizedString("REQUEST_CREATION_FAILED", tableName: "Applicationwide", bundle: Bundle.main, value: "Failed to create request.", comment: "Error reason when request could not be created")
        return NSError(domain: domain, code: 4, userInfo: [NSLocalizedDescriptionKey : localizedDescription,
            NSLocalizedFailureReasonErrorKey : localizedFailureReason])
    }
}
