//
//  StringsAnalyzer.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import Foundation

class StringsAnalyzer: ExecutableAnalyzer {
    static let stringsExecutableUrl = URL(fileURLWithPath: "/usr/bin/strings")

    private func fetch(_ url: URL) throws -> [String] {
        var stringsInFile: [String] = []

        let task = Process()
        task.executableURL = StringsAnalyzer.stringsExecutableUrl
        task.arguments = [url.path]
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        try task.run()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        let output = String(decoding: outputData, as: UTF8.self)

        for line in output.components(separatedBy: "\n") {
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

        output.tag("strings.has-usage", AnyCodable(likelyHasUsage))
        output.tag("strings.has-help-flag", AnyCodable(hasHelpFlag))
    }

    func name() -> String {
        return "strings"
    }
}
