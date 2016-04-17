//
//  PinAnnotation.swift
//  HackaBike
//
//  Created by Paulo Henrique Leite on 16/04/16.
//  Copyright © 2016 Paulo Henrique Leite. All rights reserved.
//

import MapKit
import Foundation
import UIKit

class PinAnnotation : NSObject, MKAnnotation {
    var title: String? = ""
    var subtitle: String? = ""
    var request:MKDirectionsRequest?
    var locationManager:CLLocationManager!
    
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
    
}