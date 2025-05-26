//
//  Array+FilterIf.swift
//
//
//  Created by Martin Kim Dung-Pham on 24.01.24.
//

import Foundation

extension Array {
    func filterIf(_ filter: Filter<Self.Element>?) -> [Self.Element] {
        if let filter {
            return self.filter(filter)
        } else {
            return self
        }
    }
}
