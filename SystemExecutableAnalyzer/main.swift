//
//  main.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import Foundation

let analyzers: [ExecutableAnalyzer] = [
    LipoAnalyzer(),
    StringsAnalyzer(),
    ManPageAnalyzer(),
    DynamicLinkerAnalyzer()
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

    executableCollector.sort()

    let output = AnalysisOutputCollection()

    let queue = DispatchQueue.main
    let group = DispatchGroup()
    for urlForExecutable in executableCollector.executables {
        let url = urlForExecutable
        let outputForFile = output.forExecutable(url)
        queue.async(group: group) {
            print("analyze \(url.path)")
            for analyzer in analyzers {
                do {
                    try analyzer.analyze(url, outputForFile)
                    if !outputForFile.isInCollection() {
                        print("kick \(url.path)")
                        break
                    }
                } catch {
                    print("error in analyzer \(analyzer.name()) for path \(url.path): \(error)")
                }
            }
        }
    }

    group.notify(queue: queue) {
        do {
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
        } catch {
            print("error: \(error)")
            exit(1)
        }
    }

    dispatchMain()
}

try main()
