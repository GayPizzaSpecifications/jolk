//
//  main.swift
//  ExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import Foundation

let standardExecutablePaths = [
    "/bin",
    "/sbin",
    "/usr/bin",
    "/usr/sbin",
    "/usr/libexec"
]

let standardLaunchdPaths = [
    "/System/Library/LaunchAgents",
    "/System/Library/LaunchDaemons"
]

func main() throws {
    let executableCollector = ExecutableCollector()
    for filePath in standardExecutablePaths {
        try executableCollector.scan(filePath)
    }
    executableCollector.sort()

    let launchdCollector = LaunchdCollector()
    for filePath in standardLaunchdPaths {
        try launchdCollector.scan(filePath)
    }

    let analyzers: [ExecutableAnalyzer] = [
        LipoAnalyzer(),
        StringsAnalyzer(),
        ManPageAnalyzer(),
        DynamicLinkerAnalyzer(),
        UsageExtractionAnalyzer(),
        try LaunchdAnalyzer(launchdCollector)
    ]

    let outputCollection = AnalysisOutputCollection()

    let queue = OperationQueue()
    for urlForExecutable in executableCollector.executables {
        let url = urlForExecutable
        let outputForFile = outputCollection.get(url)
        queue.addOperation {
            let start = DispatchTime.now()
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
            let end = DispatchTime.now()
            let timeInNanoseconds = end.uptimeNanoseconds - start.uptimeNanoseconds
            let ms = Double(timeInNanoseconds) / 1_000_000.0
            print("analyzed \(url.path) \(String(format: "%.2f", ms))ms")
        }
    }

    queue.addBarrierBlock {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dataEncodingStrategy = .base64
            jsonEncoder.outputFormatting = [
                .prettyPrinted,
                .withoutEscapingSlashes,
                .sortedKeys
            ]
            let result = try jsonEncoder.encode(outputCollection.encode())
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
        exit(0)
    }

    dispatchMain()
}

try main()
