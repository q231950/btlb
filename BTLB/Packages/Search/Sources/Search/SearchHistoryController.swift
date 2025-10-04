//
//  SearchHistoryController.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 07/01/2017.
//  Copyright © 2017 neoneon. All rights reserved.
//

import Foundation
import Combine
import LibraryCore

let maxSearchesCount = 15

@objc protocol SearchHistoryControllerDelegate {
    func searchHistoryDidChange(recentSearches: [SearchViewModel])
    func searchHistoryDidDelete(_ searchViewModel: SearchViewModel)
}

@objc class SearchHistoryController : NSObject {
    
    var searches = [SearchViewModel]()
    let store = NSUbiquitousKeyValueStore.default

    let searchesKey = "searches"
    let searchTermKey = "term"
    let dateKey = "date"
    let resultsCountKey = "resultsCount"
    var delegate: SearchHistoryControllerDelegate? {
        didSet {
            delegate?.searchHistoryDidChange(recentSearches: searches)
        }
    }
    
    override init() {
        super.init()
        
        searches.append(contentsOf: loadRecentSearches())

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateExternally(note:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    @objc public func didUpdateExternally(note: Foundation.Notification) {
        
        print("🦁")
        if let u = note.userInfo,
            let changes = u[NSUbiquitousKeyValueStoreChangedKeysKey] {
            
            if let store = note.object as? NSUbiquitousKeyValueStore {
                for key in changes as! [String] {
                    print(String(describing: store.array(forKey: key)))
                    if let dictionaryRepresentations = store.array(forKey: searchesKey) as? [[String: AnyObject]] {
                        searches = searchViewModelsFromJson(json: dictionaryRepresentations)
                    }
                }
            }
        }

        delegate?.searchHistoryDidChange(recentSearches: searches)
    }

    private func recentSearchFromJson(json: [String: AnyObject]) -> SearchViewModel? {
        guard let searchTerm = json[self.searchTermKey] as? String,
            let date = json[dateKey] as? Date,
            let resultsCount = json[resultsCountKey] as? Int else { return nil }

        return SearchViewModel(searchTerm: searchTerm, date: date, resultsCount: resultsCount)
    }

    private func loadRecentSearches() -> [SearchViewModel] {
        if let dictionaryRepresentations = store.array(forKey: searchesKey) as? [[String: AnyObject]] {
            return searchViewModelsFromJson(json: dictionaryRepresentations)
        }
        return [SearchViewModel]()
    }

    private func searchViewModelsFromJson(json: [[String: AnyObject]]) -> [SearchViewModel] {
        return json.compactMap({ (dict: [String: AnyObject]) -> SearchViewModel? in
            return self.recentSearchFromJson(json: dict)
        })
    }
    
    public func updateSearchHistory(searchText: String, resultCount: Int) {
        if let index = searches.firstIndex(where: {$0.searchTerm == searchText}) {
            searches.remove(at: index)
        }
        let viewModel = SearchViewModel(searchTerm: searchText, date: Date.init(), resultsCount: resultCount)
        searches.insert(viewModel, at: 0)
        
        trimSearchesToMaximumNumberOfRecentSearches()
        synchronizeSearchHistory()
        delegate?.searchHistoryDidChange(recentSearches: searches)
    }
    
    @objc public func delete(_ searchViewModel: SearchViewModel) {
        searches.removeAll(where: { $0 == searchViewModel })
        synchronizeSearchHistory()
        delegate?.searchHistoryDidChange(recentSearches: searches)
        delegate?.searchHistoryDidDelete(searchViewModel)
    }
    
    private func trimSearchesToMaximumNumberOfRecentSearches() {
        searches = Array(searches.prefix(maxSearchesCount))
    }
    
    private func synchronizeSearchHistory() {
        let dictionaryRepresentations = searches.map { (model: SearchViewModel) -> NSDictionary in
            return NSDictionary(dictionary: [searchTermKey:model.searchTerm,
                                             dateKey:model.date,
                                             resultsCountKey:model.resultsCount])
        }
        
        store.set(dictionaryRepresentations, forKey: searchesKey)
        store.synchronize()
    }
}
