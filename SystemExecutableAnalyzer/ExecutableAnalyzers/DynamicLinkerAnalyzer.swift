//
//  DynamicLinkerAnalyzer.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import AnyCodable
import Foundation
import ProcessRunner

class DynamicLinkerAnalyzer: ExecutableAnalyzer {
    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        let result = try ProcessRunner.fetchStandardOutput("/usr/bin/otool", [
            "-L",
            url.path
        ])
        let lines = result.components(separatedBy: "\n")

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
