//
//  Rota.swift
//  HackaBike
//
//  Created by Humberto Vieira on 4/17/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit


class Rota: NSObject {
    var objectId: String!
    var arrayRetas: [[Double]] = [[]]
    var personId: String!
    var nomePessoa: String!
    var tempo: String!
    var kmRota: Double!
    
    init(dictionary: AnyObject) {
        super.init()
        
        print(dictionary)
        
        self.objectId = dictionary["objectId"] as! String
        self.arrayRetas = dictionary["retasRotas"] as! [[Double]]
        
        
        if let dic = dictionary.objectForKey("tempo") {
            self.tempo = dic["iso"] as! String
        }
        
        self.nomePessoa = dictionary["nomePessoa"] as! String
        
        if let dic = dictionary.objectForKey("personId") {
            self.personId = dic["objectId"] as! String
        }
        
        self.kmRota = dictionary["kmRota"] as! Double
        
        
        
        
        
        //
        //        // Ver o array de retas
        //        if let dic = dictionary.objectForKey("pessoaId") {
        //            self.pessoaId = dic["objectId"] as! String
        //        }
        //
        //
        //        self.pessoaNome = dictionary.objectForKey("pessoaNome") as! String
        //        self.titulo = dictionary.objectForKey("titulo") as! String
        //        // Testar o geolocalization e colocar a latitude e longitude
        //
        //        if let dic = dictionary.objectForKey("localizacao") {
        //            self.latitude = dic["latitude"] as! Double
        //            self.longitude = dic["longitude"] as! Double
        //        }
    }
    
    override init() {
        super.init()
    }
    
}

