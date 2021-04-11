//
//  BackfireApp.swift
//  Shared
//
//  Created by David Jensenius on 2021-04-07.
//

import SwiftUI
import CoreData

@main
struct BackfireApp: App {
    @ObservedObject var boardManager = BLEManager()
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            #if os(iOS)
                TabView {
                    ContentView(boardManager: self.boardManager)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .tabItem {
                            Image(systemName: "speedometer")
                            Text("Dashboard")
                        }
                    TripView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .tabItem {
                            Image(systemName: "map")
                            Text("Rides")
                        }
                    BackfireAppDebug(boardManager: self.boardManager)
                        .tabItem {
                            Image(systemName: "printer")
                            Text("Raw Data")
                        }
                }
            #else
                TripView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Image(systemName: "map")
                        Text("Rides")
                    }
            #endif
        }
    }
}
