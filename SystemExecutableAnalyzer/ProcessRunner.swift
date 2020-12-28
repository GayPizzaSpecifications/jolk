//
//  ProcessRunner.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import Foundation

class ProcessRunner {
    let process: Process
    
    var standardOutput: String?
    
    init(_ command: String, _ arguments: [String]) {
        self.process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
    }
    
    func run() throws {
        let standardOutputPipe = Pipe()
        process.standardOutput = standardOutputPipe
        process.standardError = Pipe()
        
        try process.run()
        
        let outputData = try standardOutputPipe.fileHandleForReading.readToEnd()
        process.waitUntilExit()
        if outputData != nil {
            standardOutput = String(data: outputData!, encoding: .utf8)!
        } else {
            standardOutput = ""
        }
    }
}
