//
//  JolkTool.swift
//  jolk
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import ArgumentParser
import Foundation
import JolkCore

struct JolkTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "jolk",
        abstract: "macOS System Executable Analyzer"
    )

    @Flag(name: .shortAndLong, help: "Quiet Mode")
    var quiet: Bool = false

    @Option(name: .shortAndLong, help: "Maximum Current Jobs")
    var jobs: Int = 12

    @Option(name: .shortAndLong, help: "Output File")
    var output: String = "executables.json"

    @Option(name: .shortAndLong, help: "Include Files Matching Regular Expression")
    var include: String = ".*"

    func run() throws {
        let executableCollector = ExecutableCollector()
        for filePath in JolkDefaults.standardExecutablePaths {
            try executableCollector.scan(path: filePath)
        }
        executableCollector.sort()

        let launchdCollector = LaunchdCollector()
        for filePath in JolkDefaults.standardLaunchdPaths {
            try launchdCollector.scan(filePath)
        }
        try launchdCollector.process()

        var allFoundExecutables: [URL] = []
        allFoundExecutables.append(contentsOf: executableCollector.executables)

        for filePath in launchdCollector.foundExecutables.keys {
            let url = URL(fileURLWithPath: filePath)
            if !allFoundExecutables.contains(url) {
                allFoundExecutables.append(url)
            }
        }

        allFoundExecutables.sort { left, right in
            left.path.compare(right.path) == .orderedAscending
        }

        let regex = try NSRegularExpression(pattern: include)
        allFoundExecutables.removeAll { url in
            !regex.hasExactMatch(url.path)
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
        queue.maxConcurrentOperationCount = jobs
        for urlForExecutable in allFoundExecutables {
            let url = urlForExecutable
            let outputForFile = outputCollection.get(url)
            queue.addOperation {
                analyze(url, analyzers, outputForFile)
            }
        }

        queue.addBarrierBlock {
            save(outputCollection)
        }

        dispatchMain()
    }

    func analyze(_ url: URL, _ analyzers: [ExecutableAnalyzer], _ output: AnalysisOutput) {
        let start = DispatchTime.now()
        if !quiet {
            print("analyze \(url.path)")
        }
        for analyzer in analyzers {
            do {
                try analyzer.analyze(url, output)
                if !output.isInCollection() {
                    if !quiet {
                        print("kick \(url.path)")
                    }
                    break
                }
            } catch {
                print("error in analyzer \(analyzer.name()) for path \(url.path): \(error)")
            }
        }
        let end = DispatchTime.now()
        let timeInNanoseconds = end.uptimeNanoseconds - start.uptimeNanoseconds
        let milliseconds = Double(timeInNanoseconds) / 1_000_000.0
        if !quiet {
            print("complete \(url.path) \(String(format: "%.2f", milliseconds))ms")
        }
    }

    func save(_ outputCollection: AnalysisOutputCollection) {
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
                to: URL(fileURLWithPath: output),
                atomically: true,
                encoding: .utf8
            )
        } catch {
            JolkTool.exit(withError: error)
        }
        JolkTool.exit()
    }
}
