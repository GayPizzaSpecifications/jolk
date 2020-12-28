//
//  LaunchdAnalyzer.swift
//  ExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import AnyCodable
import Foundation

class LaunchdAnalyzer: ExecutableAnalyzer {
    let launchdCollector: LaunchdCollector

    var lock = UnfairLock()
    var cache: [String: [LaunchdEntry]] = [:]

    init(_ launchdCollector: LaunchdCollector) throws {
        self.launchdCollector = launchdCollector

        try prime()
    }

    private func prime() throws {
        lock.lock()
        if !cache.isEmpty {
            return
        }

        for plistUrl in launchdCollector.plists {
            guard let plist = NSDictionary(contentsOf: plistUrl) else {
                continue
            }

            var program = plist.value(forKey: "Program") as! String?
            if program == nil {
                let args = plist.value(forKey: "ProgramArguments") as! [String]?
                if args != nil {
                    let firstArgument = args?.first
                    if firstArgument != nil {
                        program = firstArgument
                    }
                }
            }

            if program != nil {
                var entries = cache[program!]
                let entry = LaunchdEntry(
                    url: plistUrl,
                    plist: plist
                )
                if entries != nil {
                    entries?.append(entry)
                } else {
                    cache[program!] = [entry]
                }
            }
        }

        lock.unlock()
    }

    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        let plists = cache[url.path]
        if plists == nil {
            return
        }

        var plistPaths: [String] = []
        var machServices: [String] = []
        for entry in plists ?? [] {
            plistPaths.append(entry.url.path)
            guard let machServicesDict = entry.plist.value(forKey: "MachServices") as! NSDictionary? else {
                continue
            }

            for key in machServicesDict.allKeys {
                let bundle = key as! String
                let value = machServicesDict.value(forKey: bundle)
                if (value is Bool? && (value as! Bool?) == true) || value is NSDictionary {
                    if !machServices.contains(bundle) {
                        machServices.append(bundle)
                    }
                }
            }
        }

        output.set("launchd.plists", AnyCodable(plistPaths))
        output.set("launchd.mach.services", AnyCodable(machServices))
    }

    func name() -> String {
        return "launchd"
    }

    struct LaunchdEntry {
        let url: URL
        let plist: NSDictionary
    }
}
