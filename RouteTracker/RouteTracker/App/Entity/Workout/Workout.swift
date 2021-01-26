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
    @objc dynamic var secondsTotal: Int
    @objc dynamic var date: Date
    
    override class func primaryKey() -> String? {
        return "activityID"
    }
    
    init (title: String?) {
        self.title = title ?? "Тренировка"
        self.pathLenght = 0
        self.secondsTotal = 0
        self.date = Date()
    }
    
    required override init() {
        self.title = "Тренировка"
        self.pathLenght = 0
        self.secondsTotal = 0
        self.date = Date()
    }
}
