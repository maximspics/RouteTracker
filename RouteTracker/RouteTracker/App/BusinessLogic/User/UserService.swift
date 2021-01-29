//
//  UserService.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 25.01.2021.
//

import Foundation
import RealmSwift

enum RegisterError: Error {
    case userFound
    case registerError
}

final class UserService {
    static var shared = UserService()
    let realm = RealmService.shared
    
    func isUserExistWith(login: String, password: String) -> Bool {
        guard realm.get(User.self)?
            .filter("login = '\(login)' AND password = '\(password)'").count == 0 else {
                return true
        }
        
        return false
    }
    
    func getUserBy(login: String, password: String) -> Results<User>? {
        guard let user = realm.get(User.self)?
                .filter("login = '\(login)' AND password = '\(password)'") else {
            return nil
        }
        return user
        
    }
    
    func register(user: User) throws {
        guard isUserExistWith(login: user.login, password: user.password) == false else {
                throw RegisterError.userFound
        }
        
        do {
            try RealmService.shared.save(items: user)
        } catch {
            throw RegisterError.registerError
        }
    }
}
