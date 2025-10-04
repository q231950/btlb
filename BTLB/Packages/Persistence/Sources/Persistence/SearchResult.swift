//
//  SearchResult.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 17.12.15.
//  Copyright © 2015 neoneon. All rights reserved.
//

import Foundation
import LibraryCore
import UIKit
import CoreData

public class SearchResult: NSObject {
    public let library: any LibraryCore.Library
    public let ISBN: String?
    public let title: String
    public let author: String
    public let image: UIImage?
    public let imageURL: URL?
    public let barcode: String?
    public let content: [Pair]
    
    public init(library: any LibraryCore.Library, ISBN: String?, title: String?, author: String?, image: UIImage?, imageURL: URL?, barcode: String?, content: [Pair]) {
        self.library = library
        self.title = title != nil ? title! : ""
        self.author = author != nil ? author! : ""
        self.ISBN = ISBN
        self.image = image
        self.imageURL = imageURL
        self.barcode = barcode
        self.content = content
    }
    
    public convenience init?(item: EDItem, libraryProvider: LibraryProvider, in context: NSManagedObjectContext) {
        var content = [Pair]()
        if let infoPairs = item.infoPair {
            for i in 0..<infoPairs.count {
                if let infoPair = infoPairs[i] as? InfoPair {
                    content.append(Pair(key: infoPair.title!, value: infoPair.value ?? ""))
                }
            }
        }

        var imageURL: URL? = nil
        if let url = item.imageURL {
            imageURL = URL(string:url)
        }

        var image: UIImage? = nil
        if let imageData = item.imageData {
            image = UIImage(data: imageData)
        }

        if let identifier = item.libraryIdentifier,
           let libraryManagedObjectId = libraryProvider.library(forIdentifier: identifier, in: context),
           let library = context.object(with: libraryManagedObjectId) as? any LibraryCore.Library {
            self.init(library: library, ISBN: item.isbn, title: item.title, author: item.author, image: image, imageURL: imageURL, barcode: item.barcode, content: content)
        } else {
            guard let libraryIdentifier = libraryProvider.defaultLibrary,
                  let library = context.object(with: libraryIdentifier) as? any LibraryCore.Library else {
                return nil
            }
            self.init(library: library, ISBN: item.isbn, title: item.title, author: item.author, image: image, imageURL: imageURL, barcode: item.barcode, content: content)
        }

    }
}
