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
    var sec = 0
    var timer: Timer?
    var hours: Int?
    var minutes: Int?
    var seconds: Int?
    var currentWorkout: Workout?
    var uuid: String?
    
    @objc func timePassed() {
        sec += 1
        hours = sec / 3600
        minutes = sec / 60 % 60
        seconds = sec % 60
    }
    
    func start() -> Workout? {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timePassed), userInfo: nil, repeats: true)
        uuid = UUID().uuidString
        currentWorkout = Workout(activityID: uuid, title: nil, totalHours: nil, totalMinutes: nil, totalSeconds: nil)
        guard let currentWorkout = currentWorkout else { return nil }
        try? realm.save(items: currentWorkout)
        return currentWorkout
    }
    
    func stop() -> Workout? {
        timer?.invalidate()
        currentWorkout = Workout(activityID: uuid, title: nil, totalHours: hours, totalMinutes: minutes, totalSeconds: seconds)
        guard let currentWorkout = currentWorkout else { return nil }
        try? realm.save(items: currentWorkout)
        sec = 0
        return currentWorkout
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
