//
//  Personn.swift
//  HackaBike
//
//  Created by Humberto Vieira on 4/17/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit

class Personn: NSObject {
    var objectId: String!
    var name: String!
    var urlPhoto: String!
    var latitude: Double!  // Geolocation
    var longitude: Double! // Geolocation
    var hiddenPerson: Bool!
    
    init(dictionary: AnyObject) {
        super.init()
        
        print(dictionary)
        
        self.objectId = dictionary["objectId"] as! String
        self.name = dictionary["name"] as! String
        
        self.urlPhoto = dictionary.objectForKey("urlPhoto") as! String
        
        // Testar o geolocalization e colocar a latitude e longitude
        
        if let dic = dictionary.objectForKey("location") {
            self.latitude =  dic["latitude"] as! Double
            self.longitude =  dic["longitude"] as! Double
        }
        
        self.hiddenPerson = dictionary.objectForKey("hiddenPerson") as! Bool
    }
    
    
    override init() {
        super.init()
        
        
    }

}
