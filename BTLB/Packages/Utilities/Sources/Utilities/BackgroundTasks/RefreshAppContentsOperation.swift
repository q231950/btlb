//
//  RefreshAppContentsOperation.swift
//  
//
//  Created by Martin Kim Dung-Pham on 19.11.22.
//

import Foundation
import CoreData
import LibraryCore

public final class RefreshAppContentsOperation: Operation, @unchecked Sendable {

    private let updater: AccountUpdating
    private let context: NSManagedObjectContext
    private var onFinished: ((UpdateResult) -> Void)?

    private var executingInternal = false
    public override var isExecuting: Bool {
        get {
            return executingInternal
        }
    }
    var finishedInternal = false
    public override var isFinished: Bool {
        get {
            return finishedInternal
        }
    }

    public init(updater: AccountUpdating, context: NSManagedObjectContext, onFinished: ((UpdateResult) -> Void)?) {
        self.updater = updater
        self.context = context
        self.onFinished = onFinished
    }

    public override func main() {
        startExecution()

        Task {
            let updateResult = try await updater.update(in: context)
            onFinished?(updateResult)
            finish()
        }
    }

    private func startExecution() {
        self.willChangeValue(forKey: "isExecuting")
        self.executingInternal = true
        self.didChangeValue(forKey: "isExecuting")
    }

    private func finish() {
        self.willChangeValue(forKey: "isExecuting")
        self.executingInternal = false
        self.didChangeValue(forKey: "isExecuting")

        self.willChangeValue(forKey: "isFinished")
        self.finishedInternal = true
        self.didChangeValue(forKey: "isFinished")
    }
}
