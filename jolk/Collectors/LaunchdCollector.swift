//
//  LaunchdCollector.swift
//  jolk
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import Foundation

class LaunchdCollector {
    var plists: [URL] = []

    func scan(_ path: String) throws {
        let url = URL(fileURLWithPath: path, isDirectory: true)

        let urlsForPlists = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: []
        )

        for urlForPlist in urlsForPlists {
            if !urlForPlist.path.hasSuffix(".plist") {
                continue
            }
            plists.append(urlForPlist)
        }
    }
}
