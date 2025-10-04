//
//  PushNotificationManager.swift
//  
//
//  Created by Martin Kim Dung-Pham on 14.12.22.
//

import Foundation

private struct PushToken: Encodable {
    let token: String

    init(data: Data) {
        self.token = data.map { String(format: "%02x", $0) }.joined()
    }
}

public struct PushNotificationManager {

    public init() {}

    public func register(token data: Data) async throws {
        let token = PushToken(data: data)
        let pushTokenData = try JSONEncoder().encode(token)
        let urlSession = URLSession(configuration: .ephemeral)
        var request = URLRequest(url: API.pushNotificationServerUrl)
        request.httpMethod = "POST"
        request.httpBody = pushTokenData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, urlResponse) = try await urlSession.data(for: request)
        print("\(data)")
        print("\((urlResponse as! HTTPURLResponse).statusCode)")
    }
}
