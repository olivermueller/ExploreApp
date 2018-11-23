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
    case signs = "theme_signs"
    case augmentedsigns = "theme_augmented_signs"
    case normalsigns = "theme_normal_signs"
    static var themeString:String = "theme_signs"
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
        case Theme.signs:
            return try! VNCoreMLModel(for: MyCustomObjectDetectorV2().model)//uses all data -> augmented and hand annotated
        case Theme.augmentedsigns:
            return try! VNCoreMLModel(for: generatedmodel().model)//augmented images
        case Theme.normalsigns:
            return try! VNCoreMLModel(for: MyCustomObjectDetector().model)//hand annotated
        default:
            return try! VNCoreMLModel(for: FullMyCustomObjectDetector().model)
        }
    }
    static func GetModelData() -> [String: ModelDataContainer]
    {
        switch theme
        {
            case Theme.signs:
                return LoadModelData(name: "bobby"+Language.language.rawValue)
            case Theme.augmentedsigns:
                return LoadModelData(name: "bobby"+Language.language.rawValue)
            case Theme.normalsigns:
                return LoadModelData(name: "bobby"+Language.language.rawValue)
            default:
                return LoadModelData(name: "bobby"+Language.language.rawValue)
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


