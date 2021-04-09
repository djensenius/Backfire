//
//  LocationViewModel.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-08.
//

import MapKit
class LocationViewModel: ObservableObject {
  var locations = [CLLocationCoordinate2D]()

    func load(rideLocations: [Location]) {
        fetchLocations(rideLocations: rideLocations)
  }

    private func fetchLocations(rideLocations: [Location]) {
        locations = rideLocations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
    }
}
