//
//  Path.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 21.01.2021.
//

import Foundation
import RealmSwift

class Path: Object {
    @objc dynamic var pathID: String = UUID.init().uuidString
    @objc dynamic var latitude: Double
    @objc dynamic var longitude: Double
    @objc dynamic var timestamp: Date
    @objc dynamic var activityID: String
    
    override class func primaryKey() -> String? {
        return "pathID"
    }
    
    init(activityID: String, latitude: Double, longitude: Double) {
        self.activityID = activityID
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = Date()
    }
    
    required override init() {
        self.activityID = ""
        self.latitude = 0
        self.longitude = 0
        self.timestamp = Date()
    }
}
