//
//  TestHelper.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 25.08.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import CoreData
import XCTest

public enum DataType {
    case html
    case json
    case xml
}

public final class TestHelper {

    public init() {}
    
    /// @return data from the fixture with the given file name and type
    /// @details uses html as default file type
    public static func data(resource: String, type: DataType = .html, bundle: Bundle? = nil) -> Data {
        let bundle = bundle ?? Bundle.module
        let path: String?
        switch type {
        case .html:
            path = bundle.path(forResource: resource, ofType: "html")
        case .json:
            path = bundle.path(forResource: resource, ofType: "json")
        case .xml:
            path = bundle.path(forResource: resource, ofType: "xml")
        }

        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        return data
    }
}
