//
//  ExecutableAnalyzer.swift
//  ExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import Foundation

protocol ExecutableAnalyzer {
    func analyze(_ url: URL, _ output: AnalysisOutput) throws
    func name() -> String
}
