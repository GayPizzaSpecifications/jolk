//
//  LipoAnalyzer.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import ProcessRunner
import Foundation

class LipoAnalyzer: ExecutableAnalyzer {
    static let lipoExecutableUrl = URL(fileURLWithPath: "/usr/bin/lipo")

    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        let result = try system(command: "lipo", "-archs", "\(url.path)", captureOutput: true)
        let archInfoStrings = result.standardOutput.components(separatedBy: " ")
        var arches: [String] = []

        for archInfo in archInfoStrings {
            let cleanArchInfo = archInfo.trimmingCharacters(in: CharacterSet([
                "\n",
                " "
            ]))

            if cleanArchInfo.isEmpty {
                continue
            }

            arches.append(cleanArchInfo)
        }

        if arches.isEmpty {
            output.isNotExecutable()
        } else {
            output.tag("lipo.architectures", AnyCodable(arches))
        }
    }

    func name() -> String {
        return "lipo"
    }
}
