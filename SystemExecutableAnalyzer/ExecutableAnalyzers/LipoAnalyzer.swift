//
//  LipoAnalyzer.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import Foundation

class LipoAnalyzer: ExecutableAnalyzer {
    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        let process = ProcessRunner("/usr/bin/lipo", [
            "-archs",
            url.path
        ])
        try process.run()
        let archInfoStrings = process.standardOutput!.components(separatedBy: " ")
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
