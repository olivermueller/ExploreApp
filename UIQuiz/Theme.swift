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
            return try! VNCoreMLModel(for: SqueezeNet().model)
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
}

