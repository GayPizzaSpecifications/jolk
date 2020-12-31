//
//  DynamicLinkerAnalyzer.swift
//  jolk
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import AnyCodable
import Foundation

public class DynamicLinkerAnalyzer: ExecutableAnalyzer {
    public init() {}

    public func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        let result = try ProcessRunner.run("/usr/bin/otool", [
            "-L",
            url.path
        ])
        let lines = result.standardOutput.components(separatedBy: "\n")

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

            if !linkedFiles.contains(linkedFilePath) {
                linkedFiles.append(linkedFilePath)
            }

            if linkedFilePath.contains(".framework/") {
                let frameworkBasePath = linkedFilePath.components(separatedBy: ".framework/").first!
                let frameworkPath = "\(frameworkBasePath).framework"
                if !linkedFrameworks.contains(frameworkPath) {
                    linkedFrameworks.append(frameworkPath)
                }
            }
        }
        output.set("dynamic-linker.linked-files", AnyCodable(linkedFiles))
        output.set("dynamic-linker.linked-frameworks", AnyCodable(linkedFrameworks))
    }

    public func name() -> String {
        return "dynamic-linker"
    }
}
