//
//  ContentView.swift
//  Backfire Vision
//
//  Created by David Jensenius on 2024-06-17.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    let persistenceController = PersistenceController.shared

    var body: some View {
        VStack {
            TripView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .tabItem {
                    Image(systemName: "map")
                    Text("Rides")
                }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
