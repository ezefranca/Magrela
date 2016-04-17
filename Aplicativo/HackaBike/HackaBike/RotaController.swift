//
//  RotaController.swift
//  HackaBike
//
//  Created by Humberto Vieira on 4/17/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit
import Alamofire

class RotaController: NSObject {
    
    class func retornaTodosRotas(personId: String ,completionHandler: ([Rota]) ->() ) {
        
        var arrayPeople = [Rota]()
        //let parameters = ["where":["personId":["$regex":"^\(personId)"]]]
        let request = Alamofire.request(.GET, kBASE_URL + "/1/classes/Rota", parameters: nil, headers: kHEADERS)
        
        
        request.responseJSON { (response) in
            
            do {
                let responseDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                
                if let jsonResults = responseDictionary.objectForKey("results") as? [[String: AnyObject]] {
                    
                    for json in jsonResults {
                        let p = Rota(dictionary: json)
                        
                        arrayPeople.append(p)
                    }
                    
                    completionHandler(arrayPeople)
                }
                
            } catch {
                print("erro ao serializar")
            }
        }
    }
    
    
    class func insertRota(rota: Rota, completionHandler: (String?) -> ()) {
        print(rota.arrayRetas)
        let parameters = [
            "retasRotas": rota.arrayRetas, //[0.0: 0.0, 10.1: 11.3]
            "personId" : [
                "objectId": rota.personId,
                "__type": "Pointer",
                "className": "Person"
            ],
            "nomePessoa" : rota.nomePessoa,
            "tempo": ["__type": "Date",
                "iso": rota.tempo],
            "kmRota": rota.kmRota
        ]
        
        
        let request = Alamofire.request(.POST, kBASE_URL + "/1/classes/Rota", parameters: parameters as? [String : NSObject], headers: kHEADERS, encoding: .JSON)
        
        request.responseJSON { (response:Response<AnyObject, NSError>) -> Void in
            do {
                let responseDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                print(responseDictionary)
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

}
