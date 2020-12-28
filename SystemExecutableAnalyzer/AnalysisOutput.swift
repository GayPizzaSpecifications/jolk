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

    init(_ collection: AnalysisOutputCollection, _ url: URL) {
        self.collection = collection
        self.url = url
    }

    func tag(_ key: String, _ value: AnyCodable) {
        collection.tag(url.path, key, value)
    }

    func isNotExecutable() {
        collection.output.removeValue(forKey: url.path)
    }

    func isInCollection() -> Bool {
        return collection.output.keys.contains(url.path)
    }
}
