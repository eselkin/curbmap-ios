//
//  User.swift
//  curbmap
//
//  Created by Eli Selkin on 7/14/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import Foundation
import Alamofire

class User {
    var username: String
    var password: String
    var loggedIn: Bool
    var remember: Bool = false
    var session: String
    var score: Int64
    var badge: String
    var pointsAdded: [MapMarker]
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.loggedIn = false
        self.pointsAdded = []
        self.badge = "beginner"
        self.score = 0
        self.session = ""
    }
    func set_badge(badge: String) {
        self.badge = badge
    }
    func get_badge() -> String{
        return self.badge
    }
    func set_score(score: Int64) {
        self.score = score
    }
    func get_score() -> Int64 {
        return self.score
    }
    func set_session(session: String) {
        self.session = session
    }
    func get_session() -> String {
        return self.session
    }
    func set_username(username: String) {
        self.username = username
    }
    func get_username() -> String {
        return self.username
    }
    func set_password(password: String) -> Void {
        self.password = password
    }
    func set_remember(remember: Bool) -> Void {
        self.remember = remember
    }
    func get_password() -> String {
        return self.password
    }
    func login(callback: @escaping ()->Void) -> Void {
        let parameters = [
            "username": self.username,
            "password": self.password
        ]
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        var full_dictionary: [String: Any] = ["success": false]
        Alamofire.request("https://curbmap.com/login", method: .post, parameters: parameters, headers: headers).responseJSON { [weak self] response in
            guard let strongSelf = self else { return }
            if var json = response.result.value as? [String: Any] {
                json["success"] = true
                full_dictionary = json
                self?.runDict(full_dictionary: full_dictionary, callback: callback)
            }
        }
        print(full_dictionary)
        if (full_dictionary["success"] as! Bool == true) {
            
        }
    }
    
    func runDict(full_dictionary: [String: Any], callback: ()->Void) {
        self.set_badge(badge: full_dictionary["badge"] as! String)
        self.set_score(score: (Int64)((full_dictionary["score"] as! NSString).intValue))
        self.set_session(session: full_dictionary["session"] as! String)
        self.loggedIn = true
        callback()
    }
    
    func isLoggedIn() -> Bool {
        return self.loggedIn;
    }
}
