//
//  AnalysisOutputCollection.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import Foundation

class AnalysisOutputCollection {
    var output: [String: [String: AnyCodable]] = [:]

    func tag(_ path: String, _ key: String, _ value: AnyCodable) {
        if output[path] == nil {
            output[path] = [:]
        }

        output[path]![key] = value
    }

    func forExecutable(_ url: URL) -> AnalysisOutput {
        return AnalysisOutput(self, url)
    }
}
