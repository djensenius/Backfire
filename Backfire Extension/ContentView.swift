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

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var lm = LocationManager.init()
    @ObservedObject var boardManager = BLEManager()
    @State var healthtracking = HealthTracking()
    @State private var didLongPress = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ride.timestamp, ascending: false)],
        animation: .default)

    private var items: FetchedResults<Ride>

    var body: some View {
        VStack {
            Spacer()
            if (boardManager.isConnected) {
                Button(action: {
                    self.boardManager.disconnect()
                    timer.invalidate()
                    healthtracking.stopHeathTracking()
                    lm.stopMonitoring()
                })
                {
                    ZStack {
                        VStack {
                            Text("\(boardManager.speed) km/h")
                                .font(.title2)
                                .padding(.bottom)
                            Text("Trip: \( String(format: "%.1f", Float(boardManager.tripDistance) / 10)) km")
                                .font(.footnote)
                            Text("Battery: \(boardManager.battery)%")
                                .font(.footnote)
                            Text(boardManager.mode)
                                .font(.footnote)
                            if (currentRide != nil) {
                                Text("Tap to end")
                                    .font(.footnote)
                            }
                        }
                        Circle()
                            .stroke(Color.black, lineWidth: 10)
                        Circle()
                            .trim(from: 0, to: (CGFloat(boardManager.battery) + 1) / 100)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [Color.red, Color.green]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(350)
                                ),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            ).rotationEffect(.degrees(-90))
                    }.frame(idealWidth: 250, idealHeight: 250, alignment: .center)
                }.buttonStyle(PlainButtonStyle())
            } else {
                Text("You have \(items.count) rides")
                Button("Connect and Ride") {
                    lm.startMonitoring()
                    boardManager.startScanning()
                    addRide()
                    healthtracking.startHealthTracking()
                }
            }
        }
    }
    func addRide() {
        currentRide = Ride(context: self.viewContext)
        currentRide?.timestamp = Date()
        currentRide?.device = "Apple Watch"
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
            let weather = Weather(context: self.viewContext)
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
            let locationObject = Location(context: self.viewContext)
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
        ContentView()
    }
}
