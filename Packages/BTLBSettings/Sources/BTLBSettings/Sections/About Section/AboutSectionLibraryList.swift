//
//  SettingsLibraryList.swift
//  
//
//  Created by Martin Kim Dung-Pham on 06.05.23.
//

import Foundation

struct AboutSectionLibraryList: Decodable {

    let libraries: [AboutSectionLibrary]

    enum CodingKeys: String, CodingKey {
        case libraries
    }
}

struct AboutSectionLibrary: Decodable, Identifiable {

    let description: String
    let name: String
    let url: URL?
    let id: UUID = UUID()

    init(name: String, description: String, url: URL? = nil) {
        self.name = name
        self.description = description
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case description
        case name
        case url
    }
}
