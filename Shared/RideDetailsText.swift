//
//  RideDetailsText.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-12.
//

import SwiftUI
import MapKit

struct RideDetails {
    var title: String
    var value: String
    var image: Image?
}

struct RideDetailsText: View {
    @ObservedObject var ride: Ride
    let localizeNumber = LocalizeNumbers()

    @State var parsedRideDetails: [RideDetails?] = []

    var body: some View {
        let helper = Helper()
        let rideDetails = helper.parseRide(ride: ride)
        let formattedWeather = helper.formatWeather(weather: ride.weather!)

        let gridItems = [GridItem(.adaptive(minimum: 150))]

        VStack() {
            if parsedRideDetails.count > 0 {
                LazyVGrid(columns: gridItems, spacing: 5) {
                    ForEach((0...(parsedRideDetails.count - 1)), id: \.self) { index in
                        if ((parsedRideDetails[index]?.image) != nil) {
                            boxViewImage(text: parsedRideDetails[index]!.image!, value: parsedRideDetails[index]?.value ?? "")
                        } else {
                            boxView(text: parsedRideDetails[index]?.title ?? "", value: parsedRideDetails[index]?.value ?? "")
                        }

                    }
                }
            }
        }.onAppear {
            if (rideDetails != nil) {
                parsedRideDetails = buildViews(rideDetails: rideDetails!, formattedWeather: formattedWeather)
            }
        }
    }

    func boxView(text: String, value: String, divider: Bool = false) -> AnyView {
        return AnyView(
            VStack() {
                if divider {
                    Divider()
                        .padding([.top, .bottom])
                }
                Text(text)
                    .font(.title3)
                    .padding(.bottom)
                    .overlay(Divider(), alignment: .bottom)
                Text(value)
                    .font(.largeTitle)
            }.padding(.bottom, 30)
        )
    }

    func boxViewImage(text: Image, value: String, divider: Bool = false) -> AnyView {
        return AnyView(
            VStack() {
                if divider {
                    Divider()
                        .padding([.top, .bottom])
                }
                Text("\(text)")
                    .font(.title3)
                    .padding(.bottom)
                    .overlay(Divider(), alignment: .bottom)
                Text(value)
                    .font(.largeTitle)
            }.padding(.bottom, 30)
        )
    }

    func buildViews(rideDetails: DetailRide, formattedWeather: DetailWeather?) -> [RideDetails] {

        // Left
        let rideDistance = RideDetails(title: "Distance", value: localizeNumber.distance(distance: Double(rideDetails.distance) / 1000, length: 2))
        let maxSpeed = RideDetails(title: "Max Speed", value: localizeNumber.speed(speed: rideDetails.maxSpeed))
        let climb = RideDetails(title: "Climb", value: localizeNumber.height(distance: rideDetails.climb))
        let batteryStart = RideDetails(title: "Battery Start", value: "\(rideDetails.startBattery)%")
        let temprature = RideDetails(title: "Temprature", value: localizeNumber.temp(temp: formattedWeather?.feelsLike ?? 0))
        let feelsLike = RideDetails(title: "Feels Like", value: localizeNumber.temp(temp: formattedWeather?.feelsLike ?? 0))

        // Right
        let rideTime = RideDetails(title: "Ride Time", value: rideDetails.rideTime)
        let avgSpeed = RideDetails(title: "Avg. Speed", value: localizeNumber.speed(speed: Int(rideDetails.avgSpeed)))
        let decline = RideDetails(title: "Decline", value: localizeNumber.height(distance: rideDetails.decline))
        let batteryEnd = RideDetails(title: "Battery End", value: "\(rideDetails.endBattery)%")
        let weatherDescription = RideDetails(title: String("\(formattedWeather!.icon)"), value: formattedWeather?.description ?? "", image: formattedWeather!.icon)
        let windSpeed = RideDetails(title: "Wind Speed", value: localizeNumber.speed(speed: Int(formattedWeather?.windSpeed ?? 0)))
        return [
            rideDistance,
            rideTime,
            maxSpeed,
            avgSpeed,
            climb,
            decline,
            batteryStart,
            batteryEnd,
            temprature,
            weatherDescription,
            feelsLike,
            windSpeed
        ]
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

/*
struct RideDetailsText_Previews: PreviewProvider {
    static var previews: some View {
        RideDetailsText()
    }
}
 */
