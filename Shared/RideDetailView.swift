//
//  RideDetailView.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-07.
//

import SwiftUI
import MapKit

struct DetailWeather {
    var temperature: Double
    var icon: Image
    var description: String
    var windSpeed: Double
    var feelsLike: Double
}

struct DetailRide {
    var maxSpeed: Int
    var distance: Double
    var rideTime: String
    var climb: Int
    var decline: Int
    var mode: String
    var startBattery: Int
    var endBattery: Int
}

struct RideDetailView: View {
    @StateObject var ride: Ride

    var body: some View {
        let rideDetails = parseRide(ride: ride)

        VStack(alignment: .leading, spacing: 10) {
            if ride.locations?.count ?? 0 > 1 {
                MapView(rideLocations: ride.locations?.allObjects as! [Location])
                    .ignoresSafeArea(edges: .top)
            }
            VStack(alignment: .leading) {
                HStack {
                    if ride.device == "Apple Watch" {
                        Text(Image(systemName: "applewatch"))
                    }
                    Text("\(ride.timestamp ?? Date(), formatter: itemFormatter)")
                        .font(.headline)
                }
                HStack {
                    Text("Distance: \(String(format:"%.02f", (rideDetails?.distance ?? 1) / 1000)) km")
                    Spacer()
                    if ride.weather != nil {
                        Text("\(formatWeather(weather: ride.weather!).icon) \(String(format:"%.01f", formatWeather(weather: ride.weather!).temperature))°")
                    }
                }
                HStack {
                    Text("Ride time: \(rideDetails?.rideTime ?? "")")
                    Spacer()
                    if ride.weather != nil {
                        Text(formatWeather(weather: ride.weather!).description)
                    }

                }
                HStack {
                    Text("Max Speed: \(rideDetails?.maxSpeed ?? 0) km/h")
                    Spacer()
                    if ride.weather != nil {
                        Text("Felt like \(String(format:"%.01f", formatWeather(weather: ride.weather!).feelsLike))°")
                    }

                }
                HStack {
                    Text("Climb: \(rideDetails?.climb ?? 0)m / Decline: \(rideDetails?.decline ?? 0)m")
                    Spacer()
                    if ride.weather != nil {
                        Text("Wind \(String(format:"%.01f", formatWeather(weather: ride.weather!).windSpeed)) km/h")
                    }
                }
                Text("Battery: \(rideDetails?.startBattery ?? 0)% - \(rideDetails?.endBattery ?? 0)% (\(rideDetails?.mode ?? "Unknown") mode)")
            }.padding()
            Spacer()
        }.background(Color("background"))
    }

    func parseRide(ride: Ride) -> DetailRide? {
        if (ride.locations == nil) {
            return nil
        }
        let locations = ride.locations?.allObjects as! [Location]
        let sortedLocations = locations.sorted {
            $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedAscending
        }
       
        let diffComponents = Calendar.current.dateComponents([.minute, .second], from: (sortedLocations.first?.timestamp)!, to: (sortedLocations.last?.timestamp)!)
        let minutes = diffComponents.minute
        let seconds = diffComponents.second
        var timeText = ""
        timeText = "\(minutes ?? 0)"

        if (seconds ?? 0 < 10) {
            timeText = "\(timeText):0\(seconds ?? 0)"
        } else {
            timeText = "\(timeText):\(seconds ?? 0)"
        }

        var totalDistance: Double = 0
        var firstLat = sortedLocations.first?.latitude
        var firstLon = sortedLocations.first?.longitude
        var altitude = sortedLocations.first?.altitude ?? 0
        var startBattery: Int16 = 0
        var endBattery: Int16 = 0
        var economy = 0
        var speed = 0
        var turbo = 0
        var decline: Double = 0
        var incline: Double = 0
        var maxSpeed = 0
        sortedLocations.dropFirst().forEach { location in
            let firsLocation = CLLocation(latitude: firstLat!, longitude: firstLon!)
            let secondLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let currentAltitude = location.altitude
            if (altitude > currentAltitude) {
                decline = decline + (altitude - currentAltitude)
            } else {
                incline = incline + (currentAltitude - altitude)
            }
            altitude = currentAltitude

            firstLat = location.latitude
            firstLon = location.longitude
            totalDistance = totalDistance + firsLocation.distance(from: secondLocation)
            if location.speed > maxSpeed {
                maxSpeed = Int(location.speed)
            }
            let mode = location.mode
            if mode == 1 {
                economy = economy + 1
            } else if mode == 2 {
                speed = speed + 1
            } else if mode == 3 {
                turbo = turbo + 1
            }

            if location.battery != 0 {
                if startBattery == 0 {
                    startBattery = location.battery
                }
                endBattery = location.battery
            }
        }
        var mostMode = "Economy"
        if speed > economy && speed > turbo {
            mostMode = "Sport"
        } else if turbo > speed && turbo > economy {
            mostMode = "Turbo"
        }
        return DetailRide(
            maxSpeed: maxSpeed,
            distance: totalDistance,
            rideTime: timeText,
            climb: Int(incline),
            decline: Int(decline),
            mode: mostMode,
            startBattery: Int(startBattery),
            endBattery: Int(endBattery)
        )
    }

    func formatWeather(weather: Weather) -> DetailWeather {
        let temp = weather.temperature - 273.15
        return DetailWeather(
            temperature: temp,
            icon: weatherIcon(icon: weather.icon ?? ""),
            description: weather.mainDescription ?? "",
            windSpeed: weather.windSpeed,
            feelsLike: weather.feelsLike - 273.15
        )
    }

    func weatherIcon(icon: String) -> Image {
        switch icon {
        case "01d":
            return Image(systemName: "sun.max.fill")
                .renderingMode(.original)
        case "02d":
            return Image(systemName: "cloud.sun.fill")
                .renderingMode(.original)
        case "03d":
            return Image(systemName: "cloud.fill")
                .renderingMode(.original)
        case "04d":
            return Image(systemName: "cloud.fill")
                .renderingMode(.original)
        case "09d":
            return Image(systemName: "cloud.rain.fill")
                .renderingMode(.original)
        case "10d":
            return Image(systemName: "cloud.sun.rain.fill")
                .renderingMode(.original)
        case "11d":
            return Image(systemName: "cloud.sun.bolt.fill")
                .renderingMode(.original)
        case "13d":
            return Image(systemName: "snow")
                .renderingMode(.original)
        case "50d":
            return Image(systemName: "cloud.fog.fill")
                .renderingMode(.original)
        case "01n":
            return Image(systemName: "moon.fill")
                .renderingMode(.original)
        case "02n":
            return Image(systemName: "cloud.moon.fill")
                .renderingMode(.original)
        case "03n":
            return Image(systemName: "cloud.fill")
                .renderingMode(.original)
        case "04n":
            return Image(systemName: "cloud.fill")
                .renderingMode(.original)
        case "09n":
            return Image(systemName: "cloud.rain.fill")
                .renderingMode(.original)
        case "10n":
            return Image(systemName: "cloud.moon.rain.fill")
                .renderingMode(.original)
        case "11n":
            return Image(systemName: "cloud.moon.bolt.fill")
                .renderingMode(.original)
        case "13n":
            return Image(systemName: "cloud.snow.fill")
                .renderingMode(.original)
        case "50n":
            return Image(systemName: "cloud.fog.fill")
                .renderingMode(.original)
        default:
            return Image(systemName: "thermometer")
                .renderingMode(.original)
        }
    }

    func details(locations: [Location]) -> AnyView {
        let sortedLocations = locations.sorted {
            $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedAscending
        }

        let diffComponents = Calendar.current.dateComponents([.minute, .second], from: (sortedLocations.first?.timestamp)!, to: (sortedLocations.last?.timestamp)!)
        let minutes = diffComponents.minute
        let seconds = diffComponents.second
        var timeText = ""
        timeText = "\(minutes ?? 0)"

        if (seconds ?? 0 < 10) {
            timeText = "\(timeText):0\(seconds ?? 0)"
        } else {
            timeText = "\(timeText):\(seconds ?? 0)"
        }

        var totalDistance: Double = 0
        var firstLat = sortedLocations.first?.latitude
        var firstLon = sortedLocations.first?.longitude
        sortedLocations.dropFirst().forEach { location in
            let firsLocation = CLLocation(latitude: firstLat!, longitude: firstLon!)
            let secondLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            firstLat = location.latitude
            firstLon = location.longitude
            totalDistance = totalDistance + firsLocation.distance(from: secondLocation)
        }

        return AnyView(
            Text("\(timeText) / \(String(format:"%.02f", totalDistance / 1000)) KMs")
                .font(.subheadline)
        )
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
}()

struct RideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RideDetailView(ride: Ride())
    }
}
