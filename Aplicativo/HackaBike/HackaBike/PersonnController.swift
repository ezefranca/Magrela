//
//  PersonnController.swift
//  HackaBike
//
//  Created by Humberto Vieira on 4/17/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit
import Alamofire


class PersonnController: NSObject {
    class func retornaTodasPessoas(pName: String , completionHandler: ([Personn]) ->() ) {
        
        var arrayPeople = [Personn]()
        //let parameters = ["where":["name":["$regex":"^\(pName)"]]]
        let request = Alamofire.request(.GET, kBASE_URL + "/1/classes/Person", parameters: nil, headers: kHEADERS)
        
        
        request.responseJSON { (response) in
            
            do {
                let responseDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                
                if let jsonResults = responseDictionary.objectForKey("results") as? [[String: AnyObject]] {
                    
                    for json in jsonResults {
                        let p = Personn(dictionary: json)
                        
                        arrayPeople.append(p)
                    }
                    
                    completionHandler(arrayPeople)
                }
                
            } catch {
                print("erro ao serializar")
            }
        }
    }
    
    
    
    class func insertPerson(person: Personn, completionHandler: (String?) -> ()) {
        
        let parameters = [
            "name" : person.name,
            "urlPhoto" : person.urlPhoto,
            "location":[
                "latitude": person.latitude,
                "longitude": person.longitude,
                "__type": "GeoPoint"
            ],
            "hiddenPerson": person.hiddenPerson
        ]
        
        
        let request = Alamofire.request(.POST, kBASE_URL + "/1/classes/Person", parameters: parameters as? [String : AnyObject], headers: kHEADERS, encoding: .JSON)
        
        request.responseJSON { (response:Response<AnyObject, NSError>) -> Void in
            do {
                let responseDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                
                if let resultObjectId = responseDictionary.objectForKey("objectId") as? String  {
                    completionHandler(resultObjectId)
                } else {
                    completionHandler(nil)
                }
                
                
            } catch _ {
                print("erro ao salvar pessoa")
            }
        }
    }
    
    
    // Manda um personn com id e latitude e longitude
    class func updatingLocationPerson(person: Personn, completionHandler: (String?) -> ()) {
        let parameters = [
            "location":[
                "latitude": person.latitude,
                "longitude": person.longitude,
                "__type": "GeoPoint"
            ]
        ]
        
        
        let urlUpdate = kBASE_URL + "/1/classes/Person/" + person.objectId
        
        let request = Alamofire.request(.PUT, urlUpdate, parameters: parameters, headers: kHEADERS, encoding: .JSON)
        
        request.responseJSON { (response:Response<AnyObject, NSError>) -> Void in
            
            do {
                let responseDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                
                if let resultObjectId = responseDictionary.objectForKey("updatedAt") as? String  {
                    
                    completionHandler(resultObjectId)
                } else {
                    completionHandler(nil)
                }
                
                
            } catch _ {
                print("erro ao salvar pessoa")
            }
        }
        
    }
}
