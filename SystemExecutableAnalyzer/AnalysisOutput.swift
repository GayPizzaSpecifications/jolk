//
//  AnalysisOutput.swift
//  SystemExecutableAnalyzer
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

    func tag(_ key: String, _ value: AnyCodable) {
        attributes[key] = value
    }

    func isNotExecutable() {
        collection.remove(self)
    }

    func isInCollection() -> Bool {
        return collection.has(self)
    }
}
