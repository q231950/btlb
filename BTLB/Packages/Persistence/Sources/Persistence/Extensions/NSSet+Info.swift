//
//  NSSet+Info.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.02.23.
//

import Foundation
import LibraryCore

extension NSSet {
    var asInfos: [LibraryCore.Info] {
        guard let items = allObjects as? [InfoPair] else { return [] }

        return items.asInfos
    }
}

extension NSOrderedSet {
    var asInfos: [LibraryCore.Info] {
        guard let items = self.array as? [InfoPair] else { return [] }

        return items.asInfos
    }
}

extension Array {
    var asInfos: [LibraryCore.Info] {
        guard let items = self as? [InfoPair] else { return [] }

        return items.map {
            LibraryCore.Info(title: $0.title ?? "", value: $0.value ?? "")
        }
    }
}
