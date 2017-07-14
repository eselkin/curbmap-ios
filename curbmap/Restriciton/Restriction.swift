//
//  Restriction.swift
//  curbmap
//
//  Created by Eli Selkin on 7/14/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import Foundation

class Restriction {
    let type: String
    let days: [Bool]
    let weeks: [Bool]
    let months: [Bool]
    init(type: String, days: [Bool], weeks: [Bool], months: [Bool]){
        self.type = type
        self.days = days
        self.weeks = weeks
        self.months = months
    }
}
