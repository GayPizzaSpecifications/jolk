//
//  LaunchdCollector.swift
//  JolkCore
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import Foundation

public class LaunchdCollector {
    public var plistFileUrls: [URL] = []
    public var foundExecutables: [String: [LaunchdEntry]] = [:]

    public init() {}

    public func scan(_ path: String) throws {
        let url = URL(fileURLWithPath: path, isDirectory: true)

        let urlsForPlists = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: []
        )

        for urlForPlist in urlsForPlists {
            if !urlForPlist.path.hasSuffix(".plist") {
                continue
            }
            plistFileUrls.append(urlForPlist)
        }
    }

    public func process() throws {
        if !foundExecutables.isEmpty {
            return
        }

        for plistUrl in plistFileUrls {
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
                var entries = foundExecutables[program!]
                let entry = LaunchdEntry(
                    url: plistUrl,
                    plist: plist
                )
                if entries != nil {
                    entries?.append(entry)
                } else {
                    foundExecutables[program!] = [entry]
                }
            }
        }
    }

    public struct LaunchdEntry {
        public let url: URL
        public let plist: NSDictionary
    }
}
