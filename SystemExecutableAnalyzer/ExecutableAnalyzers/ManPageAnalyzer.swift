//
//  ManPageAnalyzer.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import AnyCodable
import Foundation

class ManPageAnalyzer: ExecutableAnalyzer {
    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        guard let executableFileName = url.pathComponents.last else {
            output.tag("man-page.exists", AnyCodable(false))
            return
        }
        
        let manPageUrl = URL(fileURLWithPath: "/usr/share/man/man1/\(executableFileName).1")
        output.tag("man-page.exists", AnyCodable(FileManager.default.fileExists(atPath: manPageUrl.path)))
    }

    func name() -> String {
        return "man-page"
    }
}

