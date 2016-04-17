//
//  Post.swift
//  HackaBike
//
//  Created by Humberto Vieira on 4/17/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit

class Post: NSObject {
    var objectId: String!
    var pessoaId: String!
    var pessoaNome: String!
    var titulo: String!
    var latitude: Double!
    var longitude: Double!
    
    
    init(dictionary: AnyObject) {
        super.init()
        
        print(dictionary)
        
        self.objectId = dictionary["objectId"] as! String
        
        if let dic = dictionary.objectForKey("pessoaId") {
            self.pessoaId = dic["objectId"] as! String
        }
        
        self.pessoaNome = dictionary.objectForKey("pessoaNome") as! String
        self.titulo = dictionary.objectForKey("titulo") as! String
        // Testar o geolocalization e colocar a latitude e longitude
        
        if let dic = dictionary.objectForKey("localizacao") {
            self.latitude = dic["latitude"] as! Double
            self.longitude = dic["longitude"] as! Double
        }
    }
    
    
    override init() {
        super.init()
        
        
        self.objectId = ""
        self.pessoaId = ""
        self.pessoaNome = ""
        self.titulo = ""
        self.latitude = 0.0
        self.longitude = 0.0
        
        
        
    }
    
    
}

