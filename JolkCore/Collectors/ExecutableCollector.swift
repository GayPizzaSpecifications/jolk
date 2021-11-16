//
//  ExecutableCollector.swift
//  JolkCore
//
//  Created by Kenneth Endfinger on 12/27/20.
//

import Foundation

public class ExecutableCollector {
    public var executables: [URL] = []

    public init() {}

    public func scan(path: String) throws {
        let url = URL(fileURLWithPath: path)

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

    public func add(path: String) {
        executables.append(URL(fileURLWithPath: path))
    }

    public func add(url: URL) {
        executables.append(url)
    }

    public func sort() {
        executables.sort { left, right in
            left.path.compare(right.path) == .orderedAscending
        }
    }
}
