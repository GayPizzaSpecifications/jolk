//
//  AnalysisOutputCollection.swift
//  JolkCore
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import AnyCodable
import Foundation

public class AnalysisOutputCollection {
    private var lock = UnfairLock()

    public var outputs: [String: AnalysisOutput] = [:]

    public init() {}

    public func get(_ url: URL) -> AnalysisOutput {
        lock.lock()
        let maybeExistingOutput = outputs[url.path]
        if maybeExistingOutput != nil {
            lock.unlock()
            return maybeExistingOutput!
        }
        let newOutput = AnalysisOutput(self, url)
        outputs[url.path] = newOutput
        lock.unlock()
        return newOutput
    }

    public func remove(_ output: AnalysisOutput) {
        lock.lock()
        outputs.removeValue(forKey: output.url.path)
        lock.unlock()
    }

    public func has(_ output: AnalysisOutput) -> Bool {
        lock.lock()
        let result = outputs[output.url.path] != nil
        lock.unlock()
        return result
    }

    public func encode() -> [String: [String: AnyCodable]] {
        lock.lock()
        var result: [String: [String: AnyCodable]] = [:]
        for key in outputs.keys {
            result[key] = outputs[key]!.attributes
        }
        lock.unlock()
        return result
    }
}
