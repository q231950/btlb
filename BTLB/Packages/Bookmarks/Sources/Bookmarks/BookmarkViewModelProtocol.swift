//
//  File.swift
//  
//
//  Created by Martin Kim Dung-Pham on 16.02.23.
//

import Foundation
import Combine
import LibraryCore

public enum BookmarkEvent {
    /// Used for dismissing the Bookmark Detail View
    case dismiss

    /// Used for deleting a given bookmark
    case delete(bookmark: any Bookmark)
}

public protocol BookmarkViewModelProtocol {

    var bookmark: any Bookmark { get }

    var eventPublisher: PassthroughSubject<BookmarkEvent, Never> { get }

    func dismiss()

    func delete()
}
