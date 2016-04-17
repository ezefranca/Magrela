//
//  Constants.swift
//  HackaBike
//
//  Created by Humberto Vieira on 4/17/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import Foundation


    let kBASE_URL:String = "https://api.parse.com"
    let kDB_store:String = "ParseModel.sqlite"
    
    let kPARSE_APPLICATION_ID: String = "JUBo6YYq5WvmP9iDWbdvkZjuw60QDFDV5Fi5AqGH"
    let kPARSE_REST_API_KEY: String = "HScxfv0aiv3LXpLGJVyv1tMMgZS2CQnaTN5djrHR"
    let kCONTENT_TYPE_UPLOAD_IMAGE: String = "image/png"
    
    
    let kHEADERS = [
        "X-Parse-Application-Id": kPARSE_APPLICATION_ID,
        "X-Parse-REST-API-Key": kPARSE_REST_API_KEY
    ]
    
    let kHEADERS_UPLOAD = [
        "X-Parse-Application-Id": kPARSE_APPLICATION_ID,
        "X-Parse-REST-API-Key": kPARSE_REST_API_KEY,
        "Content-Type": kCONTENT_TYPE_UPLOAD_IMAGE
    ]
    
    let kHEADERS_SIGNUP = [
        "X-Parse-Revocable-Session: ": "1",
        "X-Parse-Application-Id": kPARSE_APPLICATION_ID,
        "X-Parse-REST-API-Key": kPARSE_REST_API_KEY
    ]

