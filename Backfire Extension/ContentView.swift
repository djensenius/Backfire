//
//  ContentView.swift
//  Backfire Extension
//
//  Created by David Jensenius on 2021-04-06.
//

import SwiftUI
import CoreLocation
import CoreData
import UIKit

var currentRide: Ride?
var lat: Double = 0.0
var lon: Double = 0.0
var locationList: [CLLocation] = []
var timer = Timer()
var getFirstLocationTimer = Timer()
var extendedSession = ExtendedSessionCoordinator.init()

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var lm = LocationManager.init()
    @ObservedObject var boardManager = BLEManager()
    @ObservedObject var syncMonitor: SyncMonitor = SyncMonitor.shared
    @State var healthtracking = HealthTracking()
    @State private var didLongPress = false
    @State private var useHealthKit = false
    @State private var useBackfire = false
    @State private var started = false
    @State var buttonDisabled = true

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Config.timestamp, ascending: false)],
        animation: .default)

    private var config: FetchedResults<Config>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ride.timestamp, ascending: false)],
        animation: .default)

    private var items: FetchedResults<Ride>
    private var localizeNumber = LocalizeNumbers()
    let helper = Helper()

    var body: some View {
        TabView {
            VStack {
                Spacer()
                if boardManager.isConnected == true && boardManager.isSearching == false {
                    ZStack {
                        VStack {
                            Text("\(localizeNumber.speed(speed: boardManager.speed))").font(.title2).padding(.bottom)
                            Text("Trip: \(localizeNumber.distance(distance: Double(boardManager.tripDistance) / 10))")
                                .font(.footnote)
                            Text("Battery: \(boardManager.battery)%").font(.footnote)
                            Text(boardManager.mode).font(.footnote)
                            if currentRide != nil {
                                Text("Press to end").font(.footnote)
                            }
                        }
                        CircleView(battery: CGFloat(boardManager.battery))
                    }.frame(idealWidth: 250, idealHeight: 250, alignment: .center)
                    .onLongPressGesture {
                        print("Long press")
                        self.boardManager.disconnect()
                        timer.invalidate()
                        if healthtracking.tracking == true {
                            healthtracking.stopHeathTracking()
                        }
                        lm.stopMonitoring()
                        extendedSession.invalidate()
                        /*
                        extendedSession.start()
                        Timer.scheduledTimer(withTimeInterval: 300, repeats: false,
                                             block: {_ in
                                                extendedSession.invalidate()
                                             })
                         */
                    }
                } else if config.count > 0 && config[0].useBackfire == false && started == true {
                    // Get speed and distance from location manager
                    ZStack {
                        VStack {
                            if lm.location?.speed != nil {
                                let speed = Measurement(
                                    value: lm.location!.speed,
                                    unit: UnitSpeed.metersPerSecond
                                ).converted(to: .kilometersPerHour)
                                Text("\(localizeNumber.speed(speed: Int(speed.value)))")
                                    .font(.title2)
                                    .padding(.bottom)
                            }
                            Text("Trip: \(localizeNumber.distance(distance: Double(lm.totalDistance)))")
                                .font(.footnote)
                            if currentRide != nil {
                                Text("Press to end")
                                    .font(.footnote)
                            }
                        }
                    }.frame(idealWidth: 250, idealHeight: 250, alignment: .center)
                    .onLongPressGesture {
                        print("Long press")
                        timer.invalidate()
                        if healthtracking.tracking == true {
                            healthtracking.stopHeathTracking()
                        }
                        started = false
                        lm.stopMonitoring()
                        extendedSession.invalidate()
                    }
                } else if boardManager.isSearching == true {
                    Text("You have \(items.count) rides")
                    ProgressView()
                    Text("Connecting to Board")
                    Button("End Ride") {
                        if boardManager.isSearching == true {
                            self.boardManager.stopScanningAndResetData()
                        } else {
                            self.boardManager.disconnect()
                        }
                        timer.invalidate()
                        if healthtracking.tracking == true {
                            healthtracking.stopHeathTracking()
                        }
                        extendedSession.invalidate()
                        lm.stopMonitoring()
                    }
                } else if config.count > 0 && config[0].useBackfire == false && started == false {
                    Text("To connect to a Backfire Board connection swipe to settings.")
                    Spacer()
                    Text("You have \(items.count) rides")
                    // Add sync stuff here
                    Button("Ride!") {
                        started = true
                        addRide()
                        extendedSession.start()
                        if config.count > 0 && config[0].useHealthKit == true {
                            healthtracking.startHealthTracking()
                        }
                    }.onAppear {
                        getFirstLocationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true,
                            block: {_ in
                                getFirstLocation()
                        })
                    }.task {
                        await lm.startMonitoring()
                        await lm.fetchTheWeather()
                    }
                } else {
                    // Add sync stuff here
                    if syncMonitor.syncStateSummary.isBroken ||
                        syncMonitor.syncStateSummary.inProgress {
                        Image(systemName: syncMonitor.syncStateSummary.symbolName)
                            .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                    } else {
                        Image(systemName: syncMonitor.syncStateSummary.symbolName)
                            .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                    }
                    Spacer()
                    Text("You have \(items.count) rides")
                    Button("Connect and Ride!") {
                        boardManager.startScanning()
                        addRide()
                        extendedSession.start()
                        if config.count > 0 && config[0].useHealthKit == true {
                            healthtracking.startHealthTracking()
                        }
                    }.onAppear {
                        getFirstLocationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true,
                            block: {_ in
                                getFirstLocation()
                        })
                    }.task {
                        await lm.startMonitoring()
                        await lm.fetchTheWeather()
                    }
                }
            }.onAppear(perform: {
                configureSettings()
            })

            SettingsView()
                .environment(\.managedObjectContext, viewContext)
        }
    }

    func configureSettings() {
        if config.count > 0 && config[0].useHealthKit == true {
            useHealthKit = true
        } else {
            useHealthKit = false
        }

        if config.count > 0 && config[0].useBackfire == true {
            useBackfire = true
        } else {
            useBackfire = false
        }
    }

    func addRide() {
        Task {
            await lm.startMonitoring()
        }
        currentRide = Ride(context: self.viewContext)
        currentRide?.timestamp = Date()
        currentRide?.device = "Apple Watch"
        do {
            try self.viewContext.save()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true,
                                 block: {_ in
                                    updateLoaction()
                                 })
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may
            // be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error 3 \(nsError), \(nsError.userInfo)")
        }
    }

    func getFirstLocation() {
        if lm.location?.coordinate.latitude != nil &&
            (lm.location?.coordinate.latitude != lat || lm.location?.coordinate.longitude != lon) {
            lat = (lm.location?.coordinate.latitude)!
            lon = (lm.location?.coordinate.longitude)!
            buttonDisabled = false
            Task {
                await lm.fetchTheWeather()
            }
            getFirstLocationTimer.invalidate()
            if !started {
                print("Stopping location monitoring from first")
                lm.stopMonitoring()
            }
        }
    }

    func updateLoaction() {
        if currentRide?.weather == nil && lm.weather != nil {
            let weather = getWeather()
            currentRide?.weather = weather
            do {
                try self.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may
                // be useful during development.
                let nsError = error as NSError
                print(nsError)
                fatalError("Unresolved error 4 \(nsError), \(nsError.userInfo)")
            }
        }
        if lm.location?.coordinate.latitude != nil &&
            (lm.location?.coordinate.latitude != lat || lm.location?.coordinate.longitude != lon) {
            lat = (lm.location?.coordinate.latitude)!
            lon = (lm.location?.coordinate.longitude)!
            locationList.append(lm.location!)
            let locationObject = Location(context: self.viewContext)
            locationObject.latitude = lat
            locationObject.longitude = lon
            locationObject.timestamp = Date()
            locationObject.altitude = lm.location?.altitude ?? 0

            if config.count > 0 && config[0].useBackfire == true {
                if boardManager.battery != 0 {
                    locationObject.battery = Int16(boardManager.battery)
                }

                if boardManager.modeNum != 0 {
                    locationObject.mode = Int16(boardManager.modeNum)
                }
            }

            if lm.location?.speed != nil {
                let speed = Measurement(
                    value: lm.location!.speed,
                    unit: UnitSpeed.metersPerSecond
                ).converted(to: .kilometersPerHour)
                locationObject.speed = Int16(speed.value)
            }

            currentRide?.addToLocations(locationObject)
            do {
                try self.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it
                // may be useful during development.
                let nsError = error as NSError
                print(nsError)
                fatalError("Unresolved error 5\(nsError), \(nsError.userInfo)")
            }
        }
    }

    func getWeather() -> Weather {
        let theWeather = Weather(context: viewContext)
        let weather = helper.getWeather(lm: lm, weather: theWeather)
        return weather
    }
}

struct CircleView: View {
    var battery: CGFloat
    var body: some View {
        Circle()
            .trim(from: 0, to: (battery + 1) / 100)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [Color.red, Color.green]),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(350)
                ),
                style: StrokeStyle(lineWidth: 10, lineCap: .round)
            ).rotationEffect(.degrees(-90))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
