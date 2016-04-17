//
//  Singleton.swift
//  Voice Legacy
//
//  Created by Paulo Henrique Leite on 9/24/15.
//  Copyright (c) 2015 Humberto, Paulo, Polyana e Ramon. All rights reserved.
//

import Foundation

class Singleton {
    
    var floatingActionButton: LiquidFloatingActionButton!
    var deviceAtual: String?
    var dispositivosBluetooth: DevicesVC?
    var pessoaAtual: Personn?

    
    class var sharedInstance: Singleton {
        struct Static {
            static var instance: Singleton?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = Singleton()
        }
        return Static.instance!
    }
}