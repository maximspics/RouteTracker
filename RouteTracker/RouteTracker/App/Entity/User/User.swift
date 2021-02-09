//
//  User.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 22.01.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login: String
    @objc dynamic var password: String
    @objc dynamic var firstName: String
    @objc dynamic var lastName: String
    @objc dynamic var avatarUrl: String
    
    override class func primaryKey() -> String? {
        return "login"
    }
    
    init (login: String?, password: String?, firstName: String?, lastName: String?) {
        self.login = login ?? ""
        self.password = password ?? ""
        self.firstName = firstName ?? ""
        self.lastName = lastName ?? ""
        self.avatarUrl = ""
    }
    
    required override init() {
        self.login = ""
        self.password = ""
        self.firstName = ""
        self.lastName = ""
        self.avatarUrl = ""
    }
}
