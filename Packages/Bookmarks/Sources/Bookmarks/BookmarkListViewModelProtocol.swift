//
//  BookmarkListViewModel.swift
//  
//
//  Created by Martin Kim Dung-Pham on 15.02.23.
//

import Foundation
import Combine

import ArchitectureX
import LibraryCore

public protocol BookmarkListViewModelProtocol: ObservableObject {

    var searchText: String { get set }

    func show(_ bookmark: any Bookmark, coordinator: any Coordinator)
}
