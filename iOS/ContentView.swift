//
//  ContentView.swift
//  Shared
//
//  Created by David Jensenius on 2021-04-05.
//

import SwiftUI
import CoreLocation

var currentRide: Ride?
var lat: Double = 0.0
var lon: Double = 0.0
var locationList: [CLLocation] = []
var timer = Timer()


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var boardManager: BLEManager
    @StateObject var lm = LocationManager.init()

    var body: some View {
        VStack (alignment: .center, spacing: 10) {
            ZStack {
                rideDetails()
                Circle()
                    .stroke(Color.gray, lineWidth: 10)
                batteryPorgress()
            }.frame(idealWidth: 250, idealHeight: 250, alignment: .center)

            Spacer()
            startStopButton()
            Spacer()
        }
        .padding()
    }

    func batteryPorgress() -> AnyView {
        return AnyView(
            VStack {
                Text("\(boardManager.speed) km/h")
                    .font(.largeTitle)
                    .padding(.bottom)
                Text("Trip: \( String(format: "%.1f", Float(boardManager.tripDistance) / 10)) km")
                    .font(.title2)
                Text("Battery: \(boardManager.battery)%")
                    .font(.title2)
                Text(boardManager.mode)
                    .font(.title2)
            }
        )
    }
    func rideDetails() -> AnyView {
        return AnyView(
            VStack {
                Text("\(boardManager.speed) km/h")
                    .font(.largeTitle)
                    .padding(.bottom)
                Text("Trip: \( String(format: "%.1f", Float(boardManager.tripDistance) / 10)) km")
                    .font(.title2)
                Text("Battery: \(boardManager.battery)%")
                    .font(.title2)
                Text(boardManager.mode)
                    .font(.title2)
            }
        )
    }

    func startStopButton() -> AnyView {
        return AnyView(
            HStack(alignment: .center) {
                VStack (alignment: .center, spacing: 10) {
                    if boardManager.isConnected == false && boardManager.isSearching == false {
                        connectAndRideButton()
                    } else if boardManager.isSearching == true {
                        reconnectButton()
                    } else if boardManager.isConnected == true {
                        Button(action: {
                            stop()
                        }) {
                            Text("End Ride")
                        }
                    }
                }
            }
        )
    }

    func connectAndRideButton() -> AnyView {
        return AnyView(
            Button(action: {
                addRide()
            }) {
                Text("Connect and Ride")
            }.onAppear(perform: {
                lm.startMonitoring()
            })
        )
    }

    func reconnectButton() -> AnyView {
        return AnyView(
            Button(action: {
                stop()
            }) {
                VStack {
                    Text("Connecting to board")
                    Text("End Ride")
                }
            }
        )
    }

    func stop() {
        if boardManager.isSearching == true {
            self.boardManager.stopScanningAndResetData()
        } else {
            self.boardManager.disconnect()
        }
        lm.stopMonitoring()
        timer.invalidate()
    }

    func addRide() {
        self.boardManager.startScanning()
        currentRide = Ride(context: viewContext)
        currentRide?.timestamp = Date()
        #if os(iOS)
        currentRide?.device = UIDevice().model
        #else
        currentRide?.device = "macOS"
        #endif
        do {
            try self.viewContext.save()
            lm.fetchTheWeather()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true,
                                 block: {_ in
                                    updateLoaction()
                                 })
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error 3 \(nsError), \(nsError.userInfo)")
        }
    }

    func updateLoaction() {
        if (currentRide?.weather == nil && lm.weather.current != nil) {
            let weather = Weather(context: viewContext)
            weather.clouds = Int16(lm.weather.current?.clouds ?? 0)
            weather.feelsLike = lm.weather.current?.feelsLike ?? 0
            weather.humidity = Int16(lm.weather.current?.humidity ?? 0)
            weather.icon = lm.weather.current?.weather[0].icon ?? ""
            weather.mainDescription = lm.weather.current?.weather[0].main ?? ""
            weather.temperature = lm.weather.current?.temp ?? 0
            weather.timestamp = Date()
            weather.uvi = lm.weather.current?.uvi ?? 0
            weather.weatherDescription = lm.weather.current?.weather[0].weatherDescription ?? ""
            weather.windDeg = Int16(lm.weather.current?.windDeg ?? 0)
            weather.windSpeed = lm.weather.current?.windSpeed ?? 0
            weather.visibility = Int16(lm.weather.current?.visibility ?? 0)
            weather.dt = Int32(lm.weather.current?.dt ?? 0)
            weather.dewPoint = lm.weather.current?.dewPoint ?? 0
            weather.sunset = Int32(lm.weather.current?.sunrise ?? 0)
            weather.sunrise = Int32(lm.weather.current?.sunrise ?? 0)
            currentRide?.weather = weather
            do {
                try self.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                print(nsError)
                fatalError("Unresolved error 4 \(nsError), \(nsError.userInfo)")
            }
        }
        if (lm.location?.coordinate.latitude != nil && (lm.location?.coordinate.latitude != lat || lm.location?.coordinate.longitude != lon)) {
            lat = (lm.location?.coordinate.latitude)!
            lon = (lm.location?.coordinate.longitude)!
            locationList.append(lm.location!)
            let locationObject = Location(context: viewContext)
            locationObject.latitude = lat
            locationObject.longitude = lon
            locationObject.timestamp = Date()
            locationObject.altitude = lm.location?.altitude ?? 0

            if boardManager.speed != 0 {
                locationObject.speed = Int16(boardManager.speed)
            }

            if boardManager.battery != 0 {
                locationObject.battery = Int16(boardManager.battery)
            }

            if boardManager.modeNum != 0 {
                locationObject.mode = Int16(boardManager.modeNum)
            }

            currentRide?.addToLocations(locationObject)
            do {
                try self.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                print(nsError)
                fatalError("Unresolved error 5\(nsError), \(nsError.userInfo)")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(boardManager: BLEManager()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ContentView(boardManager: BLEManager()).preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }

    }
}
