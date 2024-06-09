//
//  Helper.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-12.
//

import Foundation
import MapKit
import SwiftUI

struct DetailWeather {
    var temperature: Double
    var temperatureUnit: String
    var icon: Image
    var iconColor: Image
    var description: String
    var windSpeed: Double
    var windSpeedUnit: String
    var feelsLike: Double
    var feelsLikeUnit: String
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
    var avgSpeed: Double
}

class Helper {
    @Environment(\.colorScheme) var colorScheme

    func parseRide(ride: Ride) -> DetailRide? {
        if ride.locations == nil {
            return nil
        }
        guard let locations = ride.locations?.allObjects as? [Location] else {
            fatalError("Could not cast locations")
        }
        let sortedLocations = locations.sorted {
            $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedAscending
        }

        let diffComponents = Calendar.current.dateComponents(
            [.minute, .second],
            from: (sortedLocations.first?.timestamp)!,
            to: (sortedLocations.last?.timestamp)!
        )
        let minutes = diffComponents.minute
        let seconds = diffComponents.second
        var timeText = ""
        timeText = "\(minutes ?? 0)"

        if seconds ?? 0 < 10 {
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
            if altitude > currentAltitude {
                decline += (altitude - currentAltitude)
            } else {
                incline += (currentAltitude - altitude)
            }
            altitude = currentAltitude

            firstLat = location.latitude
            firstLon = location.longitude
            totalDistance += firsLocation.distance(from: secondLocation)
            if location.speed > maxSpeed {
                maxSpeed = Int(location.speed)
            }
            let mode = location.mode
            if mode == 1 {
                economy += 1
            } else if mode == 2 {
                speed += 1
            } else if mode == 3 {
                turbo += 1
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

        let rideTime = Calendar.current.dateComponents(
            [.second],
            from: (sortedLocations.first?.timestamp)!,
            to: (sortedLocations.last?.timestamp)!
        )
        let totalHours = Measurement(value: Double(rideTime.second!), unit: UnitDuration.seconds).converted(to: .hours)
        let avgSpeed: Double = (totalDistance / 1000) / totalHours.value

        return DetailRide(
            maxSpeed: maxSpeed,
            distance: totalDistance,
            rideTime: timeText,
            climb: Int(incline),
            decline: Int(decline),
            mode: mostMode,
            startBattery: Int(startBattery),
            endBattery: Int(endBattery),
            avgSpeed: avgSpeed
        )
    }

    func formatWeather(weather: Weather?) -> DetailWeather {
        var icon: Image?
        let iconColor = weatherIcon(icon: weather?.icon ?? "")
        if colorScheme == .dark {
            icon = iconColor
        } else {
            icon = iconColor.renderingMode(.template)
        }

        if weather == nil {
            return DetailWeather(
                temperature: 0,
                temperatureUnit: "",
                icon: icon!,
                iconColor: iconColor,
                description: "",
                windSpeed: 100.0,
                windSpeedUnit: "",
                feelsLike: 100.0,
                feelsLikeUnit: ""
            )
        }

        return DetailWeather(
            temperature: weather!.temperature,
            temperatureUnit: weather?.temperatureUnit ?? "",
            icon: icon!,
            iconColor: iconColor,
            description: weather!.mainDescription ?? "",
            windSpeed: weather!.windSpeed,
            windSpeedUnit: weather?.windSpeedUnit ?? "",
            feelsLike: weather!.feelsLike,
            feelsLikeUnit: weather?.feelsLikeUnit ?? ""
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
}
