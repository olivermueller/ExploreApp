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
    case place = "theme_place"
    case general = "theme_general"
    case food = "theme_food"
    case flowers = "theme_flowers"
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
        case Theme.general:
            return try! VNCoreMLModel(for: signs().model)
        case Theme.place:
            return try! VNCoreMLModel(for: GoogLeNetPlaces().model)
        case Theme.food:
            return try! VNCoreMLModel(for:Food101().model)
        case Theme.flowers:
            return try! VNCoreMLModel(for:Oxford102().model)
        default:
            return try! VNCoreMLModel(for: SqueezeNet().model)
        }
    }
    static func GetModelData() -> [String: ModelDataContainer]
    {
        switch theme
        {
            case Theme.general:
                return LoadModelData(name: "SqueezeNet")
            case Theme.place:
                return LoadModelData(name: "GoogLeNetPlaces")
            case Theme.food:
                return LoadModelData(name: "Food101")
            case Theme.flowers:
                return LoadModelData(name: "Oxford102")
            default:
                return LoadModelData(name: "SqueezeNet")
        }
    }
    static func LoadModelData(name : String) -> [String: ModelDataContainer]
    {
        let path = Bundle.main.path(forResource: name, ofType: "json")
        
//        print(path!)
        
        let url = URL(fileURLWithPath: path!)
//        print(url)
        
        let data = try! Data(contentsOf: url)
//        let obj = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
//        print(obj)
        let decoder = JSONDecoder()
        do {
            let products = try decoder.decode([String: ModelDataContainer].self, from: data)
            return products
        } catch  {
//            print("shit")
            return [String: ModelDataContainer]()
        }
        
//        let jsonDecoder = JSONDecoder()
        
//        if let path = Bundle.main.url(forResource: "ModelData/"+name, withExtension: "json")
//        {
//            do
//            {
//                let data = try Data(contentsOf: path, options: .mappedIfSafe)
//                print(data.count)
//                let products = try JSONDecoder()
//                    .decode([FailableDecodable<ModelDataContainer>].self, from: data)
////                let ModelData = try jsonDecoder.decode([ModelDataContainer].self, from: data)
//                return [ModelDataContainer]()
//            }
//            catch
//            {
//                    print("ROFL")
//            }
//        }
    }
}


