//
//  RealmService.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 21.01.2021.
//

import Foundation
import RealmSwift

class RealmService {
    static var shared = RealmService()
    let deleteIfMigration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    var realm: Realm?
    
    init() {
        realm = try? Realm(configuration: deleteIfMigration)
    }

    func get<T: Object>(_ type: T.Type) -> Results<T>? {
        return realm?.objects(type) ?? nil
    }
    
    func save<T: Object>(items: T) throws {
        try realm?.write {
            realm?.add(items.self, update: Realm.UpdatePolicy.modified)
        }
    }
    
    func delete<T: Object>(items: T) throws {
        try realm?.write {
            realm?.delete(items)
        }
    }
        
    func delete<T: Object>(items: Results<T>) throws {
        try realm?.write {
            realm?.delete(items)
        }
    }
}
