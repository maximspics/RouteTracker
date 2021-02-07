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
    
    func stop(distance: Double?, userLogin: String?, urlScreenshot: String?) {
        if let currentWorkout = currentWorkout {
            let startTime = currentWorkout.date.timeIntervalSince1970
            let endTime = Date().timeIntervalSince1970
            
            try? realm.realm?.write {
                currentWorkout.userLogin = userLogin ?? ""
                currentWorkout.secondsTotal = Int(endTime) - Int(startTime)
                currentWorkout.pathLenght = distance ?? 0
                currentWorkout.urlScreenshot = urlScreenshot ?? ""
            }
            
            self.currentWorkout = nil
        }
    }
    
    func list(_ userLogin: String) -> [Workout]? {
        guard let workouts = realm.get(Workout.self)?
                .filter("userLogin = '\(userLogin)'")
                .sorted(byKeyPath: "date", ascending: false) else { return nil }
        return workouts.map { return $0 }
    }
    
    func count(_ userLogin: String) -> Int {
        return list(userLogin)?.count ?? 0
    }
    
    func remove(activityID: String) -> Bool {
        guard let workout = realm.get(Workout.self)?.filter("activityID = '\(activityID)'"), workout.isEmpty == false,
              let _ = try? realm.delete(items: workout) else { return false }
        
        return true
    }
    
    func loadBy(activityID: String) -> Workout? {
        guard let workoutFromDb = realm.get(Workout.self)?.filter("activityID = '\(activityID)'"),
              workoutFromDb.isEmpty == false else { return nil }
        
        return workoutFromDb.first
    }
}
