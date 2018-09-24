//
//  Theme.swift
//  UIQuiz
//
//  Created by Niels Østman on 10/03/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import UIKit
import Vision

enum Theme : String {
    case flowers = "theme_flowers"
    case signs = "theme_signs"
    static var themeString:String = "theme_general"
    static let ThemeKey:String = "Theme"
    static var theme: Theme {
        get {
            themeString = UserDefaults.standard.string(forKey: ThemeKey)!
            let theme = Theme(rawValue: themeString)
            //print("found " + (theme?.rawValue)!)
            return theme!
        }
        set {
            guard theme != newValue else {
                return
            }
            themeString = newValue.rawValue
            UserDefaults.standard.set(themeString, forKey: ThemeKey)
            print("Set new theme: " + themeString)
            UserDefaults.standard.synchronize()
        }
    }
    static func GetModel() -> VNCoreMLModel{
        switch theme {
        case Theme.flowers:
            return try! VNCoreMLModel(for: oxford102().model)
        case Theme.signs:
            return try! VNCoreMLModel(for: bobby().model)
        default:
            return try! VNCoreMLModel(for: oxford102().model)
        }
    }
    static func GetModelData() -> [String: ModelDataContainer]
    {
        switch theme
        {
            case Theme.flowers:
                return LoadModelData(name: "oxford102")
            case Theme.signs:
                return LoadModelData(name: "signs")
            default:
                return LoadModelData(name: "oxford102")
        }
    }
    static func LoadModelData(name : String) -> [String: ModelDataContainer]
    {
        let path = Bundle.main.path(forResource: name, ofType: "json")
        
        let url = URL(fileURLWithPath: path!)
        
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        do {
            let products = try decoder.decode([String: ModelDataContainer].self, from: data)
            return products
        } catch  {
            return [String: ModelDataContainer]()
        }
    }
}


