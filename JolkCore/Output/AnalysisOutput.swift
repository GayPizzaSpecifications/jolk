//
//  AnalysisOutput.swift
//  JolkCore
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import Foundation

public class AnalysisOutput {
    public let collection: AnalysisOutputCollection
    public let url: URL

    public var attributes: [String: AnyCodable] = [:]

    public init(_ collection: AnalysisOutputCollection, _ url: URL) {
        self.collection = collection
        self.url = url
    }

    public func set(_ key: String, _ value: AnyCodable) {
        attributes[key] = value
    }

    public func get(_ key: String) -> AnyCodable {
        return attributes[key] ?? AnyCodable()
    }

    public func get(bool: String) -> Bool {
        let result = get(bool)
        if result.value is Bool {
            return result.value as! Bool
        }
        return false
    }

    public func has(_ key: String) -> Bool {
        return attributes.keys.contains(key)
    }

    public func isNotExecutable() {
        collection.remove(self)
    }

    public func isInCollection() -> Bool {
        return collection.has(self)
    }

    public static func create(for url: URL) -> AnalysisOutput {
        let collection = AnalysisOutputCollection()
        return collection.get(url)
    }
}
