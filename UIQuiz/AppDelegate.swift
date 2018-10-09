//
//  AppDelegate.swift
//  UIQuiz
//
//  Created by Niels Østman on 09/03/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import UIKit
import CoreML
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    enum ShortcutIdentifier: String {
        case OpenExplore
        case OpenQuiz
        case OpenLearn
        case OpenSettings
        
        init?(fullIdentifier: String) {
            self.init(rawValue: fullIdentifier)
        }
    }
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let standardDefaults = UserDefaults.standard
        standardDefaults.register(defaults: ["Progress":0])
        standardDefaults.register(defaults: ["Level":1])
        standardDefaults.register(defaults: [Theme.ThemeKey : Theme.signs.rawValue])
        standardDefaults.register(defaults: ["UUID" : ""])
        standardDefaults.register(defaults: ["Name" : "John"])
        standardDefaults.register(defaults: ["Email" : "John@johnson.com"])
        print("After: " + standardDefaults.string(forKey: "UUID")!)
        // Uncomment to reset score
//        standardDefaults.setValue("John", forKey: "Name")
//        standardDefaults.setValue(Theme.signs.rawValue, forKey: Theme.ThemeKey)
//        standardDefaults.setValue("John@johnson.com", forKey: "Email")
//        standardDefaults.setValue(Language.english.rawValue, forKey: "AppleLanguages")
//        standardDefaults.setValue(Theme.signs.rawValue, forKey: Theme.ThemeKey)
        //standardDefaults.setValue(0, forKey: "Progress")
        //standardDefaults.setValue(1, forKey: "Level")
        
        switch standardDefaults.string(forKey: Theme.ThemeKey)! {
        case Theme.signs.rawValue:
            Theme.theme = Theme.signs
        case Theme.augmentedsigns.rawValue:
            Theme.theme = Theme.augmentedsigns
        case Theme.normalsigns.rawValue:
            Theme.theme = Theme.normalsigns
        default:
            Theme.theme = Theme.signs
        }
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            handleShortcut(shortcutItem)
            return false
        }
        return true
    }
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        
        completionHandler(handleShortcut(shortcutItem))
    }
    
    @discardableResult fileprivate func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }
        
        return selectTabBarItemForIdentifier(shortcutIdentifier)
    }
    
    fileprivate func selectTabBarItemForIdentifier(_ identifier: ShortcutIdentifier) -> Bool {
        
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return false
        }
        
        switch (identifier) {
        case .OpenExplore:
            tabBarController.selectedIndex = 0
            return true
        case .OpenQuiz:
            tabBarController.selectedIndex = 1
            return true
        case .OpenLearn:
            tabBarController.selectedIndex = 2
            return true
        case .OpenSettings:
            tabBarController.selectedIndex = 3
            return true
        }
    }
}

