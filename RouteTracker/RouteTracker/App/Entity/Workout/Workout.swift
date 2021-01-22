//
//  Workout.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 21.01.2021.
//

import Foundation
import RealmSwift

class Workout: Object {
    @objc dynamic var activityID: String = UUID.init().uuidString
    @objc dynamic var title: String
    @objc dynamic var pathLenght: Double
    var timeTotal: String { (totalHours == 0 ? "" : String(totalHours) + " ч. ") + (totalMinutes == 0 ? "" : String(totalMinutes) + " мин. ") + String(totalSeconds) + " сек." }
    @objc dynamic var totalHours: Int
    @objc dynamic var totalMinutes: Int
    @objc dynamic var totalSeconds: Int
    @objc dynamic var timestamp: Date
    
    override class func primaryKey() -> String? {
        return "activityID"
    }
    
    init (activityID: String?, title: String?, totalHours: Int?, totalMinutes: Int?, totalSeconds: Int?) {
        self.activityID = activityID ?? ""
        self.title = title ?? "Тренировка"
        self.pathLenght = 0
        self.totalHours = totalHours ?? 0
        self.totalMinutes = totalMinutes ?? 0
        self.totalSeconds = totalSeconds ?? 0
        self.timestamp = Date()
    }
    
    required override init() {
        self.title = "Тренировка"
        self.pathLenght = 0
        self.totalHours = 0
        self.totalMinutes = 0
        self.totalSeconds = 0
        self.timestamp = Date()
    }
}
