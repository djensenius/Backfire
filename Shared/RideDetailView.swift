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

        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if ride.locations?.count ?? 0 > 1 {
                    ZStack(alignment: .topTrailing) {
                        if ride.locations?.count ?? 0 > 1 {
                            MapView(rideLocations: ride.locations!.allObjects)
                                .frame(height: 200)
                        }
                        VStack {
                            VStack {
                                Text("\(formattedWeather.iconColor) \(localizeNumber.temp(temp: formattedWeather.temperature))")
                            }.padding(5)
                        }
                        .background(Color("AccentColor").opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .padding(5)

                    }
                }
                if ride.locations?.count ?? 0 > 0 {
                    RideDetailsText(ride: ride)
                } else {
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
