////
////  Request+Extensions.swift
////  biblib
////
////  Created by Martin Kim Dung-Pham on 11.05.15.
////  Copyright (c) 2015 Martin Kim Dung-Pham. All rights reserved.
////
//
//import Foundation
//
//let baseUrlString = "www.buecherhallen.de"
//
//extension URLRequest {
//    
//    static func request(method: String, host: String = baseUrlString, path: String, body: Data? = nil, parameters: [String: AnyHashable] = [:], headers: [String: String] = [:]) -> URLRequest? {
//        var request: URLRequest?
//        
//        if let url = URL(string: "https://\(host)/")?.appendingPathComponent(path) {
//            request = URLRequest(url: url)
//            request?.httpMethod = method
//            headers.forEach { (key, value) in
//                request?.addValue("\(value)", forHTTPHeaderField: key)
//            }
//            let parameterStrings = parameters.compactMap { (key: String, value: AnyHashable) -> String in
//                return "\(key)=\(value)"
//            }
//            if let body = body {
//                request?.httpBody = body
//            } else {
//                let postString = parameterStrings.joined(separator: "&")
//                request?.httpBody = postString.data(using: .utf8)
//            }
//        }
//        
//        return request as URLRequest?
//    }
//}
//
//extension URLRequest {
//
//    public static func ed_authenticatedURLRequest(accountIdentifier: String, password: String, URL: Foundation.URL) -> URLRequest? {
//        let timeoutInterval: TimeInterval = 3;
//
//        var path = URL.absoluteString + "&BOR_U=" + accountIdentifier.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        path += "&BOR_PW=" + password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        if let newURL = Foundation.URL(string: path) {
//            let request = NSMutableURLRequest(url: newURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeoutInterval)
//            request.httpMethod = "POST"
//            return request as URLRequest
//        }
//
//        return nil
//    }
//}
//
//extension NSObject {
//
//    static func request(_ username:String, password:String, path: String) -> URLRequest? {
//        // konto/entliehene_medien/kundendaten/kontostand/vormerkungen/vormerkguthaben/
//        let urlString = baseUrlString + path
//        
//        var request: URLRequest?
//        if let url = URL(string:urlString) {
//            request = URLRequest(url: url)
//            request?.httpMethod = "GET"
//        }
//        
//        return request as URLRequest?
//    }
//
//    // needs to be called after successful sign in to have valid cookies
//    static func renewRequest(_ itemID: String) -> URLRequest? {
////        let escapedItemID = itemID.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
//        let urlString = baseUrlString + "verlaengern" + "?in=\(String(describing: itemID))"
//
//        var request: URLRequest?
//        if let url = URL(string:urlString) {
//            request = URLRequest(url: url)
//        }
//        return request
//    }
//}
