//
//  WhiteShirt.swift
//  
//
//  Created by Martin Kim Dung-Pham on 26.08.23.
//

import Combine
import Foundation
import os
import SwiftUI

public final class WhiteShirt {
    public var isDirty = CurrentValueSubject<Bool, Never>(false)

    public init() {}

    private var values = NSMapTable<NSString, ObservedValue>.init(
        keyOptions: .copyIn,
        valueOptions: .weakMemory
    )

    public func observeValue(named key: String, affectsDirtyness: Bool = true, onSave: @escaping (String, String) -> Void) -> ObservedValue {
        let value = ObservedValue(onSave: onSave) { [weak self] newValue in
            if affectsDirtyness {
                self?.updateDirtynessState()
            }
        }

        values.setObject(value, forKey: NSString(string: key))

        return value
    }

    public func save() {
        Logger.utilities.debug("\(type(of: self)) save")
        values.dictionaryRepresentation().values.forEach {
            $0.saveCurrentText()
        }

        updateDirtynessState()
    }

    private func updateDirtynessState() {
        let dirty = values.dictionaryRepresentation().values.contains { $0.isDirty }

        isDirty.send(dirty)
    }
}

public final class ObservedValue {

    public var isDirty: Bool {
        savedText.value != text
    }
    
    /// new value
    private let onUpdate: (String) -> Void
    private let onSave: (String, String) -> Void
    public var savedText = CurrentValueSubject<String, Never>("")
    public var text: String = "" {
        didSet {
            onUpdate(text)
        }
    }

    public init(onSave: @escaping (String, String) -> Void, onUpdate: @escaping (String) -> Void) {
        self.onSave = onSave
        self.onUpdate = onUpdate
    }

    func saveCurrentText() {
        let oldText = savedText.value
        savedText.send(text)
        onSave(oldText, text)
    }
}
