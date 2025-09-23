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
    /// Used for deleting a given bookmark
    case delete(bookmark: any Bookmark)
}

@MainActor
public protocol BookmarkViewModelProtocol: ObservableObject {

    var bookmark: any Bookmark { get }

    @MainActor var showsDeleteConfirmation: Bool { get set }

    var eventPublisher: PassthroughSubject<BookmarkEvent, Never> { get }

    @MainActor func delete()
}
