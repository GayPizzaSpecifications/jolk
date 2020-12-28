//
//  StringsAnalyzer.swift
//  ExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import Foundation
import ProcessRunner

class StringsAnalyzer: ExecutableAnalyzer {
    private func fetch(_ url: URL) throws -> [String] {
        let result = try ProcessRunner.run("/usr/bin/strings", [
            url.path
        ])
        var stringsInFile: [String] = []

        for line in result.standardOutput.components(separatedBy: "\n") {
            if !line.isEmpty {
                stringsInFile.append(line)
            }
        }

        return stringsInFile
    }

    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        let stringsInFile = try fetch(url)

        var likelyHasUsage = false
        var hasHelpFlag = false
        for line in stringsInFile {
            if line.starts(with: "Usage: ") ||
                line.starts(with: "usage: ") {
                likelyHasUsage = true
            }

            if line == "--help" {
                likelyHasUsage = true
                hasHelpFlag = true
            }
        }

        output.set("strings.likely.has-usage", AnyCodable(likelyHasUsage))
        output.set("strings.likely.has-help-flag", AnyCodable(hasHelpFlag))
    }

    func name() -> String {
        return "strings"
    }
}
