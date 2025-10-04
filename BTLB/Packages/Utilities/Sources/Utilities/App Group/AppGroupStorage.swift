//
//  AppGroupStorage.swift
//  
//
//  Created by Martin Kim Dung-Pham on 30.11.22.
//

import Foundation

public struct AppGroupStorage {

    public init() {}

    public func store(_ content: Codable, name: String) throws {
        let url = AppGroup.btlb.containerURL.appendingPathComponent("\(name).json")
        let data = try JSONEncoder().encode(content)
        try data.write(to: url)
    }

    public func read<T: Decodable>(named name: String) throws -> T {
        let url = AppGroup.btlb.containerURL.appendingPathComponent("\(name).json")

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

}
