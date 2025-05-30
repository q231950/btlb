//
//  BookmarkViewModel.swift
//  
//
//  Created by Martin Kim Dung-Pham on 15.02.23.
//

import Combine
import CoreData
import Foundation
import ArchitectureX

import LibraryCore
import Persistence

public final class BookmarkViewModel: BookmarkViewModelProtocol, ObservableObject {

    @Published public var bookmark: any Bookmark
    public var eventPublisher: PassthroughSubject<BookmarkEvent, Never> = PassthroughSubject<BookmarkEvent, Never>()

    public init(bookmark: any Bookmark) {
        self.bookmark = bookmark
    }

    public func dismiss() {
        eventPublisher.send(.dismiss)
    }

    public func delete() {
        eventPublisher.send(.delete(bookmark: bookmark))
    }
}
