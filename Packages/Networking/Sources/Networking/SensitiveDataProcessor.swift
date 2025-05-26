//
//  SensitiveDataProcessor.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 14.03.20.
//  Copyright © 2020 elbedev. All rights reserved.
//

#if canImport(StubbornNetwork)
import Foundation
import StubbornNetwork

/**

 */
struct SensitiveDataProcessor: BodyDataProcessor {
    func textByStrippingSensitiveData(from text: String) -> String {
        var processed = text.replacingOccurrences(of: "<pin>(.*)</pin>", with: "<pin>***</pin>", options: [.caseInsensitive, .regularExpression])
        processed = processed.replacingOccurrences(of: "<Brwr>((.|\n)*)</Brwr>", with: "<Brwr>A12 345 678 9</Brwr>", options: [.caseInsensitive, .regularExpression])
        processed = processed.replacingOccurrences(of: "<borrowerNumber>(.*)</borrowerNumber>", with: "<borrowerNumber>123456789</borrowerNumber>", options: [.caseInsensitive, .regularExpression])
        processed = processed.replacingOccurrences(of: "<BrwrRecNum>(.*)</BrwrRecNum>", with: "<BrwrRecNum>999999999</BrwrRecNum>", options: [.regularExpression])
        processed = processed.replacingOccurrences(of: "<userId>(.*)</userId>", with: "<userId>123456789</userId>", options: [.regularExpression])
        processed = processed.replacingOccurrences(of: "<UserId>(.*)</UserId>", with: "<UserId>12345</UserId>", options: [.regularExpression])
        processed = processed.replacingOccurrences(of: "<sessionId xmlns=\"\">(.*)</sessionId>", with: "<sessionId xmlns=\"\">abc-123</sessionId>", options: [.regularExpression])
        processed = processed.replacingOccurrences(of: "<sessionId>(.*)</sessionId>", with: "<sessionId>abc-123</sessionId>", options: [.regularExpression])
        return processed
    }

    func dataForStoringRequestBody(data: Data?, of request: URLRequest) -> Data? {
        guard let unwrappedData = data, let dataAsString = String(data: unwrappedData, encoding: .utf8) else {
            return data
        }
        return textByStrippingSensitiveData(from: dataAsString).data(using: .utf8)
    }

    func dataForStoringResponseBody(data: Data?, of request: URLRequest) -> Data? {
        guard let unwrappedData = data, let dataAsString = String(data: unwrappedData, encoding: .utf8) else {
            return data
        }
        return textByStrippingSensitiveData(from: dataAsString).data(using: .utf8)
    }

    func dataForDeliveringResponseBody(data: Data?, of request: URLRequest) -> Data? {
        data
    }

}

#endif
