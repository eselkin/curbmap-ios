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
    let username: String
    let password: String
    let loggedIn: Bool
    let pointsAdded: [MapMarker]
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.loggedIn = false
        self.pointsAdded = []
    }
    func login() -> Void {
        let parameters = [
            username: self.username,
            password: self.password
        ]
        let data = Alamofire.request("https://curbmap.com/login", method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
        print(data)
    }
    
    func isLoggedIn() -> Bool {
        return self.loggedIn;
    }
}
