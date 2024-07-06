//
//  FullScreenMapView.swift
//  Backfire
//
//  Created by David Jensenius on 2024-07-06.
//

import SwiftUI

struct FullMapView: View {
    @StateObject var ride: Ride

    let localizeNumber = LocalizeNumbers()

    var body: some View {
        let helper = Helper()
        let formattedWeather = helper.formatWeather(weather: ride.weather ?? nil)
        let temp = localizeNumber.temp(temp: formattedWeather.temperature, unitName: formattedWeather.temperatureUnit)
        ZStack(alignment: .topTrailing) {
            MapView(rideLocations: ride.locations!.allObjects)
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
}
