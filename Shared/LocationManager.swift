//
//  Weather.swift
//  FluxHaus
//
//  Created by David Jensenius on 2020-12-19.
//

import Foundation
import CoreLocation
import Combine

// MARK: - OpenWeather
struct OpenWeather: Codable {
    let lat: Double
    let timezone: String
    let daily: [Daily]
    let timezoneOffset: Int
    let current: Current?
    let lon: Double
    var alerts: [Alert]?

    enum CodingKeys: String, CodingKey {
        case lat, timezone, daily
        case timezoneOffset = "timezone_offset"
        case current, lon, alerts
    }
}

// MARK: - Alert
struct Alert: Codable {
    let end: Int
    let senderName: String
    let event: String
    let description: String
    let start: Int

    enum CodingKeys: String, CodingKey {
        case end, event, description, start
        case senderName = "sender_name"
    }
}

// MARK: - Current
struct Current: Codable {
    let pressure, clouds: Int
    let weather: [TheWeather]
    let uvi: Double
    let dt: Int
    let dewPoint: Double
    let windDeg, visibility: Int
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

// MARK: - Daily
struct Daily: Codable {
    let uvi: Double
    let dt: Int
    let snow: Double?
    let clouds, pressure: Int
    let weather: [TheWeather]
    let pop: Double
    let windDeg: Int
    let dewPoint: Double
    let rain: Double?
    let sunrise: Int
    let feelsLike: FeelsLike
    let humidity: Int
    let windSpeed: Double
    let temp: Temp
    let sunset: Int

    enum CodingKeys: String, CodingKey {
        case uvi, dt, snow, clouds, pressure, weather, pop
        case windDeg = "wind_deg"
        case dewPoint = "dew_point"
        case rain, sunrise
        case feelsLike = "feels_like"
        case humidity
        case windSpeed = "wind_speed"
        case temp, sunset
    }
}

// MARK: - FeelsLike
struct FeelsLike: Codable {
    let morn, day, eve, night: Double
}

// MARK: - Temp
struct Temp: Codable {
    let night, eve, min, max: Double
    let day, morn: Double
}

// MARK: - Location services
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var status: CLAuthorizationStatus?

    @Published var location: CLLocation?
    @Published var weather = OpenWeather(lat: 0, timezone: "UTC", daily: [], timezoneOffset: 0, current: nil, lon: 0, alerts: [])

    func fetchTheWeather() {
        print("Getting Weather")
        guard let location = self.location else { return }

        guard let url = URL(
                string:
                    "https://api.openweathermap.org/data/2.5/onecall?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&exclude=minutely,hourly&appid=\(BackfireConsts.openWeatherApi)"
        ) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    if let decodedResponse = try? JSONDecoder().decode(OpenWeather.self, from: data) {
                        self.weather = decodedResponse
                    }
                }
            }
        }.resume()
    }

    func startMonitoring() {
        if ((weather.current == nil) && ((self.location?.coordinate.latitude) != nil) && ((self.location?.coordinate.longitude) != nil)) {
            fetchTheWeather()
        }
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.activityType = .fitness
        self.locationManager.startUpdatingLocation()
    }

    func stopMonitoring() {
        self.locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if (self.location?.coordinate.longitude != location.coordinate.longitude ||
                self.location?.coordinate.latitude != location.coordinate.latitude) {

            self.location = location
            if (self.weather.lat == 0 && self.weather.lon == 0) {
                self.fetchTheWeather()
            }
        }
    }
}


