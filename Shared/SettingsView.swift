//
//  SwiftUIView.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-18.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var useHealthKit = false
    @State private var useBackfire = false
    @ObservedObject var syncMonitor: SyncMonitor = SyncMonitor.shared

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Config.timestamp, ascending: false)],
        animation: .default)

    private var config: FetchedResults<Config>

    var body: some View {
        VStack {
            List {
                Toggle("HealthKit", isOn: $useHealthKit)
                    .onAppear(perform: {
                        configureHealthKit()
                    })
                    .onChange(of: useHealthKit) {
                        updateHealth(use: useHealthKit)
                    }
                Toggle("Backfire Board", isOn: $useBackfire)
                    .onAppear(perform: {
                        configureBackfire()
                    })
                    .onChange(of: useBackfire) {
                        updateBackfire(use: useBackfire)
                    }
            }
            Spacer()
            Text(syncMonitor.syncStateSummary.description)
            Image(systemName: syncMonitor.syncStateSummary.symbolName)
                     .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
        }
    }

    func updateHealth(use: Bool) {
        if config.count == 0 {
            let newConfig = Config(context: self.viewContext)
            newConfig.useHealthKit = use
        } else {
            config[0].useHealthKit = use
        }
        do {
            try self.viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved saving HealthKit \(nsError), \(nsError.userInfo)")
        }
    }

    func configureHealthKit() {
        if config.count > 0 && config[0].useHealthKit == true {
            useHealthKit = true
        } else {
            useHealthKit = false
        }
    }

    func updateBackfire(use: Bool) {
        if config.count == 0 {
            let newConfig = Config(context: self.viewContext)
            newConfig.useBackfire = use
        } else {
            config[0].useBackfire = use
        }
        do {
            try self.viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved saving HealthKit \(nsError), \(nsError.userInfo)")
        }
    }

    func configureBackfire() {
        if config.count > 0 && config[0].useBackfire == true {
            useBackfire = true
        } else {
            useBackfire = false
        }
    }
}
/*
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
*/
