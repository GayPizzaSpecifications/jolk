//
//  Extensions.swift
//  jolk
//
//  Created by Kenneth Endfinger on 1/9/21.
//

import Foundation

extension NSRegularExpression {
    func hasExactMatch(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        let match = firstMatch(in: string, options: [], range: range)
        guard let result = match else {
            return false
        }

        if result.range == range {
            return true
        }
        return false
    }
}
