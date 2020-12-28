//
//  UnfairLock.swift
//  SystemExecutableAnalyzer
//
//  Created by Kenneth Endfinger on 12/28/20.
//

import Foundation

struct UnfairLock {
    private var unfairLock = os_unfair_lock()

    mutating func lock() {
        os_unfair_lock_lock(&unfairLock)
    }

    mutating func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}
