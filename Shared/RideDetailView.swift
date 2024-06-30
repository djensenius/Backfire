//
//  RideDetailView.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-07.
//

import SwiftUI

struct RideDetailView: View {
    @StateObject var ride: Ride

    let localizeNumber = LocalizeNumbers()

    var body: some View {
        let helper = Helper()
        let formattedWeather = helper.formatWeather(weather: ride.weather ?? nil)
        let temp = localizeNumber.temp(temp: formattedWeather.temperature, unitName: formattedWeather.temperatureUnit)
        #if os(iOS)
        let size = UIDevice.current.userInterfaceIdiom == .phone ? 200.0 : 380.0
        #elseif os(visionOS)
        let size = 300.0
        #else
        let size = 380.0
        #endif

        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if ride.locations?.count ?? 0 > 1 {
                    ZStack(alignment: .topTrailing) {
                        if ride.locations?.count ?? 0 > 1 {
                            MapView(rideLocations: ride.locations!.allObjects)
                                .frame(height: size)
                        }
                        VStack {
                            VStack {
                                Text("\(formattedWeather.iconColor) \(temp)")
                            }.padding(5)
                        }
                        #if !os(visionOS)
                        .background(Color("AccentColor").opacity(0.2))
                        #endif
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .padding(5)

                    }
                }
                if ride.locations?.count ?? 0 > 0 {
                    RideDetailsText(ride: ride).padding()
                    Link(
                        "Weather provided by  Weather",
                        destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!
                    )
                    .font(.footnote)
                    .padding([.bottom, .leading])
                } else {
                    Spacer()
                    Text("Not enough ride data to show ride.")
                }
            }
        }
    }
}

struct RideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RideDetailView(ride: Ride())
    }
}
