//
//  LaunchdAnalyzer.swift
//  jolk
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import AnyCodable
import Foundation

class LaunchdAnalyzer: ExecutableAnalyzer {
    let launchdCollector: LaunchdCollector

    init(_ launchdCollector: LaunchdCollector) throws {
        self.launchdCollector = launchdCollector
    }

    func analyze(_ url: URL, _ output: AnalysisOutput) throws {
        let plists = launchdCollector.foundExecutables[url.path]
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
}
