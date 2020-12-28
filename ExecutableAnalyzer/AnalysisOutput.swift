//
//  AnalysisOutput.swift
//  ExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import Foundation

class AnalysisOutput {
    let collection: AnalysisOutputCollection
    let url: URL

    var attributes: [String: AnyCodable] = [:]

    init(_ collection: AnalysisOutputCollection, _ url: URL) {
        self.collection = collection
        self.url = url
    }

    func set(_ key: String, _ value: AnyCodable) {
        attributes[key] = value
    }

    func get(_ key: String) -> AnyCodable {
        return attributes[key] ?? AnyCodable()
    }

    func get(bool: String) -> Bool {
        let x = get(bool)
        if x.value is Bool {
            return x.value as! Bool
        }
        return false
    }

    func has(_ key: String) -> Bool {
        return attributes.keys.contains(key)
    }

    func isNotExecutable() {
        collection.remove(self)
    }

    func isInCollection() -> Bool {
        return collection.has(self)
    }
}
