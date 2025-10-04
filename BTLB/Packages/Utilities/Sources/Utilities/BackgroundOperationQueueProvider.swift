//
//  BackgroundOperationQueueProvider.swift
//  
//
//  Created by Martin Kim Dung-Pham on 19.11.22.
//

import Foundation

public final class BackgroundOperationProvider {
    public static let shared = BackgroundOperationProvider()

    public var operationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.qualityOfService = .background

        return queue
    }()
}

