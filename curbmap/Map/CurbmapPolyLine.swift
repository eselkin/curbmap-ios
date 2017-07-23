//
//  PolyLine.swift
//  curbmap
//
//  Created by Eli Selkin on 7/14/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import Foundation
import MapKit

class CurbmapPolyLine: MKPolyline {
    let coordinates: [CLLocationCoordinate2D]
    let color: String
    let restrictions: [Restriction]
    let inEffect: Bool
    init(coordinates: [CLLocationCoordinate2D], color: String, restrictions: [Restriction], inEffect: Bool) {
        self.coordinates = coordinates
        self.color = color
        self.restrictions = restrictions
        self.inEffect = inEffect
        super.init()
    }
}
