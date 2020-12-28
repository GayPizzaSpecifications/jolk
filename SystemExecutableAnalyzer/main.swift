//
//  main.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import Foundation

let analyzers: [ExecutableAnalyzer] = [
    StringsAnalyzer(),
    LipoAnalyzer()
]

func main() throws {
    let standardFilePaths = [
        "/bin",
        "/sbin",
        "/usr/bin",
        "/usr/sbin",
        "/usr/libexec"
    ]

    let executableCollector = ExecutableCollector()
    for filePath in standardFilePaths {
        try executableCollector.scan(filePath)
    }

    let output = AnalysisOutputCollection()

    for url in executableCollector.executables {
        let outputForFile = output.forExecutable(url)

        for analyzer in analyzers {
            do {
                try analyzer.analyze(url, outputForFile)
                if !outputForFile.isInCollection() {
                    break
                }
            } catch {
                print("error in analyzer \(analyzer.name()) for path \(url.path): \(error)")
            }
        }
    }

    let jsonEncoder = JSONEncoder()
    jsonEncoder.dataEncodingStrategy = .base64
    jsonEncoder.outputFormatting = [
        .prettyPrinted,
        .withoutEscapingSlashes
    ]
    let result = try jsonEncoder.encode(output.output)
    let resultToString = String(data: result, encoding: .utf8)!
    try resultToString.write(
        to: URL(fileURLWithPath: "executables.json"),
        atomically: true,
        encoding: .utf8
    )
}

try main()
