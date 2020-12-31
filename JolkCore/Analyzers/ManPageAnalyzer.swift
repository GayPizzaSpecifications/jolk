//
//  ManPageAnalyzer.swift
//  jolk
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import AnyCodable
import Foundation

public class ManPageAnalyzer: ExecutableAnalyzer {
    public init() {}

    public func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        guard let executableFileName = url.pathComponents.last else {
            output.set("man-page.exists", AnyCodable(false))
            return
        }

        let manPageUrl = URL(fileURLWithPath: "/usr/share/man/man1/\(executableFileName).1")
        output.set("man-page.exists", AnyCodable(FileManager.default.fileExists(atPath: manPageUrl.path)))
    }

    public func name() -> String {
        return "man-page"
    }
}
