//
//  Weather.swift
//  FluxHaus
//
//  Created by David Jensenius on 2020-12-19.
//

import Foundation
import CoreLocation
import Combine
import WeatherKit

// MARK: - Current
struct Current: Codable {
    let pressure, clouds: Int
    let weather: [TheWeather]
    let uvi: Double
    let dt: Int
    let dewPoint, visibility: Double
    let windDeg: Int
    let windSpeed, temp, feelsLike: Double
    let humidity, sunrise, sunset: Int

    enum CodingKeys: String, CodingKey {
        case pressure, clouds, weather, uvi, dt
        case dewPoint = "dew_point"
        case windDeg = "wind_deg"
        case visibility
        case windSpeed = "wind_speed"
        case temp
        case feelsLike = "feels_like"
        case humidity, sunrise, sunset
    }
}

// MARK: - TheWeather
struct TheWeather: Codable {
    let id: Int
    let weatherDescription, icon, main: String

    enum CodingKeys: String, CodingKey {
        case id
        case weatherDescription = "description"
        case icon, main
    }
}

// MARK: - Location services
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var status: CLAuthorizationStatus?

    @Published var weather: CurrentWeather?
    @Published var location: CLLocation?
    @Published var totalDistance: Double = 0

    var startLocation: CLLocation!
    var lastLocation: CLLocation!

    func fetchTheWeather() async {
        guard let location = self.location else { return }

        do {
            let weatherService = WeatherService()
            let weather = try await weatherService.weather(for: location)
            DispatchQueue.main.async {
                self.weather = weather.currentWeather
            }
        } catch {
            print("Error fetching weather")
        }
    }

    #if !os(visionOS)
    func startMonitoring() async {
        if (weather == nil) && ((self.location?.coordinate.latitude) != nil) &&
                ((self.location?.coordinate.longitude) != nil) {
            await fetchTheWeather()
        }
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.activityType = .fitness
        self.locationManager.allowsBackgroundLocationUpdates = true
        #if os(iOS)
            self.locationManager.pausesLocationUpdatesAutomatically = false
        #endif
        self.locationManager.startUpdatingLocation()
    }

    func stopMonitoring() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        self.locationManager.allowsBackgroundLocationUpdates = false
        self.locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if self.location?.coordinate.longitude != location.coordinate.longitude ||
                self.location?.coordinate.latitude != location.coordinate.latitude {

            if (locations.first != nil) && (locations.last != nil) {
                if startLocation == nil {
                    startLocation = locations.first
                } else if let location = locations.last {
                    totalDistance += (lastLocation.distance(from: location) / 1000)
                }
                lastLocation = locations.last
            }
            self.location = location
        }
    }
    #endif
}
