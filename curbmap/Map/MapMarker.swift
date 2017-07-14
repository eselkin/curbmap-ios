//
//  MapMarker.swift
//  curbmap
//
//  Created by Eli Selkin on 7/14/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import Foundation
import MapKit

class MapMarker: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let restrictions: [Restriction]
    let inEffect: Bool
    init(coordinate: CLLocationCoordinate2D, restrictions: [Restriction], inEffect: Bool){
        self.coordinate = coordinate
        self.restrictions = restrictions
        self.inEffect = inEffect
    }
}
