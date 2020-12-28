//
//  UsageExtractionAnalyzer.swift
//  ExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import AnyCodable
import Foundation

class UsageExtractionAnalyzer: ExecutableAnalyzer {
    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        if output.get(bool: "strings.likely.has-help-flag") {
            let result = try ProcessRunner.run(url.path, [
                "--help"
            ])

            var usage = result.standardOutput
            if usage.isEmpty {
                usage = result.standardError
            }

            if !usage.isEmpty {
                output.set("usage-extraction.usage", AnyCodable(usage))
            }
        }
    }

    func name() -> String {
        return "usage-extractor"
    }
}
