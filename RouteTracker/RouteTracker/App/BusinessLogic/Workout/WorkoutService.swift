//
//  WorkoutService.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 21.01.2021.
//

import Foundation
import RealmSwift

class WorkoutService: NSObject {
    private var realm = RealmService.shared
    var currentWorkout: Workout?
    
    func start() -> Workout? {
        let currentWorkout = Workout()
        try? realm.save(items: currentWorkout)
        self.currentWorkout = currentWorkout
        return currentWorkout
    }
    
    func stop(distance: Double?) {
        if let currentWorkout = currentWorkout {
            let startTime = currentWorkout.date.timeIntervalSince1970
            let endTime = Date().timeIntervalSince1970
            
            try? realm.realm?.write {
                currentWorkout.secondsTotal = Int(endTime) - Int(startTime)
                currentWorkout.pathLenght = distance ?? 0
            }
            
            self.currentWorkout = nil
        }
    }
    
    func list() -> [Workout]? {
        guard let workouts = realm.get(Workout.self) else { return nil }
        
        return workouts.map { return $0 }
    }
    
    func count() -> Int {
        return list()?.count ?? 0
    }
    
    func removeBy(workoutID: String) -> Bool {
        guard let workout = realm.get(Workout.self)?.filter("activityID = '\(workoutID)'"), workout.isEmpty == false,
              let _ = try? realm.delete(items: workout) else { return false }
        
        return true
    }
    
    func loadBy(workoutID: String) -> Workout? {
        guard let workoutFromDb = realm.get(Workout.self)?.filter("activityID = '\(workoutID)'"),
              workoutFromDb.isEmpty == false else { return nil }
        
        return workoutFromDb.first
    }
}
