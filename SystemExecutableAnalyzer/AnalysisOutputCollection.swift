//
//  AnalysisOutputCollection.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import Foundation

class AnalysisOutputCollection {
    private var outputs: [String: AnalysisOutput] = [:]
    private var lock = os_unfair_lock()

    func get(_ url: URL) -> AnalysisOutput {
        os_unfair_lock_lock(&lock)
        let maybeExistingOutput = outputs[url.path]
        if maybeExistingOutput != nil {
            os_unfair_lock_unlock(&lock)
            return maybeExistingOutput!
        }
        let newOutput = AnalysisOutput(self, url)
        outputs[url.path] = newOutput
        os_unfair_lock_unlock(&lock)
        return newOutput
    }
    
    func remove(_ output: AnalysisOutput) {
        os_unfair_lock_lock(&lock)
        outputs.removeValue(forKey: output.url.path)
        os_unfair_lock_unlock(&lock)
    }
    
    func has(_ output: AnalysisOutput) -> Bool {
        os_unfair_lock_lock(&lock)
        let result = outputs[output.url.path] != nil
        os_unfair_lock_unlock(&lock)
        return result
    }
    
    func encode() -> [String:[String:AnyCodable]] {
        os_unfair_lock_lock(&lock)
        var result: [String:[String:AnyCodable]] = [:]
        for key in outputs.keys {
            result[key] = outputs[key]!.attributes
        }
        os_unfair_lock_unlock(&lock)
        return result
    }
}
