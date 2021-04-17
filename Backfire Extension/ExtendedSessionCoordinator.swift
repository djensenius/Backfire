//
//  ExtendedSessionCoordinator.swift
//  Backfire Extension
//
//  Created by David Jensenius on 2021-04-17.
//

import Foundation
import SwiftUI

class ExtendedSessionCoordinator: NSObject, WKExtensionDelegate, WKExtendedRuntimeSessionDelegate {
    var session: WKExtendedRuntimeSession!

    func start() {
        guard session?.state != .running else { return }

        if session == nil || session?.state == .invalid {
            session = WKExtendedRuntimeSession()
        }
        session?.start()
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        // Do something
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Do something
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Do something
    }

    func invalidate() {
        session?.invalidate()
    }
}
