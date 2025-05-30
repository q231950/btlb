//
//  SearchResultInfo.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 17.02.16.
//  Copyright © 2016 neoneon. All rights reserved.
//

import Foundation

public class SearchResultInfo: Identifiable {

    public var id: String { identifier }

    public let identifier: String
    public let title: String?
    public let subtitle: String?
    public let number: String
    public var imageUrl: URL?
    public var detailUrl: URL?

    public init(identifier: String, title: String?, subtitle: String?, number: String, imageUrl: URL?, detailUrl: URL?) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.number = number
        self.imageUrl = imageUrl
        self.detailUrl = detailUrl
    }
}
