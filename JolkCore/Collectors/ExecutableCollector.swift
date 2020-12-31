//
//  ExecutableCollector.swift
//  jolk
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import Foundation

public class ExecutableCollector {
    public var executables: [URL] = []

    public init() {}

    public func scan(_ path: String) throws {
        let url = URL(fileURLWithPath: path, isDirectory: true)

        let urlsForExecutables = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [
                URLResourceKey.isExecutableKey
            ]
        )

        for url in urlsForExecutables {
            if try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true {
                executables.append(url)
            }
        }
    }

    public func sort() {
        executables.sort { a, b in
            a.path.compare(b.path) == .orderedAscending
        }
    }
}