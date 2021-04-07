//
//  BackfireApp.swift
//  Backfire Extension
//
//  Created by David Jensenius on 2021-04-06.
//

import SwiftUI

@main
struct BackfireApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
