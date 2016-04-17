//
//  Alert.swift
//  Foodtrack
//
//  Created by Paulo Henrique Leite on 8/22/15.
//  Copyright (c) 2015 Humberto Vieira de Castro. All rights reserved.
//
/*
    Usado para dar alertas de erro, informação ou concluido
    Em title: passar nome do alerta
    Em description: passar descrição do erro
*/

import Foundation
import UIKit

func alertError(title: String, description: String, sender: UIButton?) {
    TWMessageBarManager.sharedInstance().showMessageWithTitle(title, description: description, type: TWMessageBarMessageType.Error, statusBarStyle:UIStatusBarStyle.LightContent, callback:({() -> Void in
        if sender != nil {
            sender?.enabled = true
        }
    }))
}

func alertSucess(title: String, description: String, sender: UIButton?) {
    TWMessageBarManager.sharedInstance().showMessageWithTitle(title, description: description, type: TWMessageBarMessageType.Success, statusBarStyle:UIStatusBarStyle.LightContent, callback:({() -> Void in
        if sender != nil {
            sender?.enabled = true
        }
    }))
}

func alertInfo(title: String, description: String, sender: UIButton?) {
    TWMessageBarManager.sharedInstance().showMessageWithTitle(title, description: description, type: TWMessageBarMessageType.Info, statusBarStyle:UIStatusBarStyle.LightContent, callback:({() -> Void in
        if sender != nil {
            sender?.enabled = true
        }
    }))
}

func alertError(title: String, description: String) {
    TWMessageBarManager.sharedInstance().showMessageWithTitle(title, description: description, type: TWMessageBarMessageType.Error, statusBarStyle:UIStatusBarStyle.LightContent, callback:nil)
}

func alertSucess(title: String, description: String) {
    TWMessageBarManager.sharedInstance().showMessageWithTitle(title, description: description, type: TWMessageBarMessageType.Success, statusBarStyle:UIStatusBarStyle.LightContent, callback:nil)
}

func alertInfo(title: String, description: String) {
    TWMessageBarManager.sharedInstance().showMessageWithTitle(title, description: description, type: TWMessageBarMessageType.Info, statusBarStyle:UIStatusBarStyle.LightContent, callback:nil)
}