//
//  Network.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 25.08.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import Foundation

import NetworkShim

#if canImport(StubbornNetwork)
import StubbornNetwork
#endif

public class NetworkClient: NSObject, Network {

    let session: URLSession

    public override init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage?.cookieAcceptPolicy = .always
        if ProcessInfo().isUITesting {
            #if DEBUG
            StubbornNetwork.standard.insertStubbedSessionURLProtocol(into: configuration)
            StubbornNetwork.standard.bodyDataProcessor = SensitiveDataProcessor()
            StubbornNetwork.standard.requestMatcherOptions = .strict
            #endif
        }
        session = URLSession(configuration: configuration)
        super.init()
    }

    public func dataTask(with request: URLRequest, completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        session.dataTask(with: request, completionHandler: completionHandler)
    }

}


