//
//  LocalizeNumbers.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-11.
//

import Foundation

class LocalizeNumbers {
    func speed(speed: Int) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = Locale.current
        formatter.unitStyle = .medium
        let num = NumberFormatter()
        num.maximumFractionDigits = 0
        formatter.numberFormatter = num

        let kmh = Measurement(value: Double(speed), unit: UnitSpeed.kilometersPerHour)
        return formatter.string(from: kmh)
    }

    func distance(distance: Double, length: Int = 1) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = Locale.current
        formatter.unitStyle = .medium
        let num = NumberFormatter()
        num.maximumFractionDigits = length
        formatter.numberFormatter = num

        let kmh = Measurement(value: distance, unit: UnitLength.kilometers)
        return formatter.string(from: kmh)
    }

    func temp(temp: Double, length: Int = 1, unitName: String) -> String {
        var cel: Measurement<UnitTemperature>
        let formatter = MeasurementFormatter()
        formatter.locale = Locale.current
        formatter.unitStyle = .short
        let num = NumberFormatter()
        num.maximumFractionDigits = length
        formatter.numberFormatter = num

        switch unitName {
        case UnitTemperature.celsius.symbol:
            cel = Measurement(value: temp, unit: UnitTemperature.celsius)
        case UnitTemperature.fahrenheit.symbol:
            cel = Measurement(value: temp, unit: UnitTemperature.fahrenheit)
        default:
            cel = Measurement(value: temp, unit: UnitTemperature.kelvin)
        }

        return formatter.string(from: cel)
    }

    func height(distance: Int, length: Int = 2) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = Locale.current
        formatter.unitStyle = .medium
        let num = NumberFormatter()
        num.maximumFractionDigits = length
        formatter.numberFormatter = num

        let cel = Measurement(value: Double(distance), unit: UnitLength.meters)
        return formatter.string(from: cel)
    }
}
