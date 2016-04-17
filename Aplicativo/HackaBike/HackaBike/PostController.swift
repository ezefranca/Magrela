//
//  PostController.swift
//  HackaBike
//
//  Created by Humberto Vieira on 4/17/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit
import Alamofire

class PostController: NSObject {
    
    class func retornaTodosPosts(completionHandler: ([Post]) ->() ) {
        var arrayPeople = [Post]()
        //let parameters = ["where":["name":["$regex":"^\(pName)"]]]
        let request = Alamofire.request(.GET, kBASE_URL + "/1/classes/Post", parameters: nil, headers: kHEADERS)
        
        
        request.responseJSON { (response) in
            
            do {
                let responseDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                
                if let jsonResults = responseDictionary.objectForKey("results") as? [[String: AnyObject]] {
                    
                    for json in jsonResults {
                        let p = Post(dictionary: json)
                        
                        arrayPeople.append(p)
                    }
                    
                    completionHandler(arrayPeople)
                }
                
            } catch {
                print("erro ao serializar")
            }
        }
    }
    
    class func insertPost(post: Post, completionHandler: (String?) -> ()) {
        
        let parameters = [
            "objectId" : post.objectId,
            "pessoaId" : ["objectId" : post.pessoaNome,
                "__type": "Pointer",
                "className": "Person"],
            "localizacao":[
                "latitude": post.latitude,
                "longitude": post.longitude,
                "__type": "GeoPoint"
            ],
            "titulo": post.titulo,
            "pessoaNome": post.pessoaNome
            
        ]
        
        let request = Alamofire.request(.POST, kBASE_URL + "/1/classes/Post", parameters: parameters as? [String : AnyObject], headers: kHEADERS, encoding: .JSON)
        
        request.responseJSON { (response:Response<AnyObject, NSError>) -> Void in
            do {
                let responseDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                
                if let resultObjectId = responseDictionary.objectForKey("objectId") as? String  {
                    completionHandler(resultObjectId)
                } else {
                    completionHandler("ss")
                }
                
            } catch _ {
                print("erro ao salvar pessoa")
            }
        }
        
        
        
        
//        let request = Alamofire.request(.POST, kBASE_URL + "/1/classes/Post", parameters: parameters as? [String : NSObject], headers: kHEADERS, encoding: .JSON)
//        
//        request.responseJSON { (response:Response<AnyObject, NSError>) -> Void in
//            do {
//                let responseDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
//                print(responseDictionary)
//                if let resultObjectId = responseDictionary.objectForKey("objectId") as? String  {
//                    completionHandler(resultObjectId)
//                } else {
//                    completionHandler(nil)
//                }
//                
//                
//            } catch _ {
//                print("erro ao salvar pessoa")
//            }
 //       }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
