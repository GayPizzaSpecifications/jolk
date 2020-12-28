//
//  LipoAnalyzer.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import Foundation

class LipoAnalyzer: ExecutableAnalyzer {
    static let lipoExecutableUrl = URL(fileURLWithPath: "/usr/bin/lipo")

    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        let task = Process()
        task.executableURL = LipoAnalyzer.lipoExecutableUrl
        task.arguments = [
            "-archs",
            url.path
        ]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        try task.run()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        let outputString = String(data: outputData, encoding: .utf8)!
        let archInfoStrings = outputString.components(separatedBy: " ")
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
