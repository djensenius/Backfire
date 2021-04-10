//
//  BackfireApp.swift
//  Backfire Extension
//
//  Created by David Jensenius on 2021-04-07.
//

import SwiftUI

@main
struct BackfireApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
