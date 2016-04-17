//
//  MapHelper.swift
//  HackaBike
//
//  Created by Paulo Henrique Leite on 16/04/16.
//  Copyright © 2016 Paulo Henrique Leite. All rights reserved.
//

//import UIKit
//import CoreLocation
//
//class MapHelper: NSObject, CLLocationManagerDelegate {
//    var locationManager:CLLocationManager!
//    
//    override init() {
//        super.init()
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startUpdatingLocation()
//        locationManager.requestAlwaysAuthorization()
//    }
//    
//    
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status == .AuthorizedWhenInUse {
//            // authorized location status when app is in use; update current location
//            locationManager.startUpdatingLocation()
//            // implement additional logic if needed...
//        }
//        // implement logic for other status values if needed...
//    }
//    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
////    
////        if (s.first as? CLLocation) != nil {
////            // implement logic upon location change and stop updating location until it is subsequently updated
////            locationManager.stopUpdatingLocation()
////        }
//    }
//    
//    func retornaLocal() {
//        
//    }
//    
//    
//}
