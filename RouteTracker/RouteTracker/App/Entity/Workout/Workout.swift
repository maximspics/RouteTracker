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
    @objc dynamic var userLogin: String
    @objc dynamic var title: String
    @objc dynamic var pathLenght: Double
    @objc dynamic var secondsTotal: Int
    @objc dynamic var urlScreenshot: String
    @objc dynamic var date: Date
    
    override class func primaryKey() -> String? {
        return "activityID"
    }
    
    init (title: String?) {
        self.userLogin = ""
        self.title = title ?? "Тренировка"
        self.pathLenght = 0
        self.secondsTotal = 0
        self.urlScreenshot = ""
        self.date = Date()
    }
    
    required override init() {
        self.userLogin = ""
        self.title = "Тренировка"
        self.pathLenght = 0
        self.secondsTotal = 0
        self.urlScreenshot = ""
        self.date = Date()
    }
}
