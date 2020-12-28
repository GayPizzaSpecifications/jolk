//
//  ProcessRunner.swift
//  ExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import Foundation

class ProcessRunner {
    let process: Process

    var standardOutput: String = ""
    var standardError: String = ""

    init(_ command: String, _ arguments: [String]) {
        process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
    }

    func run() throws {
        let standardOutputPipe = Pipe()
        let standardErrorPipe = Pipe()
        process.standardOutput = standardOutputPipe
        process.standardError = standardErrorPipe

        try process.run()

        let standardOutputData = try standardOutputPipe.fileHandleForReading.readToEnd()
        let standardErrorData = try standardErrorPipe.fileHandleForReading.readToEnd()
        process.waitUntilExit()
        if standardOutputData != nil {
            standardOutput = String(data: standardOutputData!, encoding: .utf8) ?? ""
        } else {
            standardOutput = ""
        }

        if standardErrorData != nil {
            standardError = String(data: standardErrorData!, encoding: .utf8) ?? ""
        } else {
            standardError = ""
        }
    }

    static func run(_ command: String, _ arguments: [String]) throws -> ProcessRunner {
        let runner = ProcessRunner(command, arguments)
        try runner.run()
        return runner
    }
}
