//
//  DynamicLinkerAnalyzer.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import AnyCodable
import Foundation

class DynamicLinkerAnalyzer: ExecutableAnalyzer {
    static let otoolExecutableUrl = URL(fileURLWithPath: "/usr/bin/otool")

    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        let task = Process()
        task.executableURL = DynamicLinkerAnalyzer.otoolExecutableUrl
        task.arguments = [
            "-L",
            url.path
        ]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        try task.run()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: outputData, encoding: .utf8)!
        let lines = outputString.components(separatedBy: "\n")

        var linkedFiles: [String] = []
        var linkedFrameworks: [String] = []
        for line in lines {
            if line.contains(":") ||
                !line.contains("(") {
                continue
            }

            let linkedFilePath = line.components(separatedBy: "(").first!.trimmingCharacters(in: [
                " ",
                "\t"
            ])
            linkedFiles.append(linkedFilePath)

            if linkedFilePath.contains(".framework/") {
                let frameworkBasePath = linkedFilePath.components(separatedBy: ".framework/").first!
                let frameworkPath = "\(frameworkBasePath).framework"
                linkedFrameworks.append(frameworkPath)
            }
        }
        output.tag("dynamic-linker.linked-files", AnyCodable(linkedFiles))
        output.tag("dynamic-linker.linked-frameworks", AnyCodable(linkedFrameworks))
    }

    func name() -> String {
        return "dynamic-linker"
    }
}
