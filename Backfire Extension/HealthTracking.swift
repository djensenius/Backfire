//
//  HealthTracking.swift
//  Backfire Extension
//
//  Created by David Jensenius on 2021-04-09.
//

import Foundation
import HealthKit

class HealthTracking: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    var tracking: Bool = false

    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        print("Change state?")
        if toState == .ended {
            print("The workout has now ended.")
            builder.endCollection(withEnd: Date()) { (_, _) in
                self.builder.finishWorkout { (_, _) in
                    // Optionally display a workout summary to the user.
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Nothing
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        // Nothing
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Nothing
    }

    func startHealthTracking() {
        print("Starting health tracking")
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        ]

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .skatingSports
        configuration.locationType = .outdoor

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (_, _) in
            // Handle error.
        }

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            return
        }

        session.delegate = self
        builder.delegate = self
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: configuration)
        session.startActivity(with: Date())
        self.tracking = true
        builder.beginCollection(withStart: Date()) { (_, _) in
            // The workout has started.
        }
    }
    func stopHeathTracking() {
        session.end()
        self.tracking = false
    }
}
