//
//  SecondViewController.swift
//  UIQuiz
//
//  Created by Niels Østman on 09/03/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController{

    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var languagebtn: UIButton!
    @IBOutlet weak var currentLanguageLabel: UILabel!
    @IBOutlet weak var CurrentThemeLabel: UILabel!
    @IBOutlet weak var themebtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
    }
    
    @IBAction func changeTheme(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "alert_change_theme_title".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        func addActionTheme(theme: Theme) {
            alert.addAction(
                UIAlertAction(
                    title: theme.rawValue.localized,
                    style: UIAlertActionStyle.default,
                    handler: { _ in
                        Theme.theme = theme
                        self.CurrentThemeLabel.text = "main_page_current_theme".localized + ": " +  Theme.theme.rawValue.localized
                })
            )
        }
        addActionTheme(theme: Theme.food)
        addActionTheme(theme: Theme.general)
        addActionTheme(theme: Theme.place)
        
        alert.addAction(
            UIAlertAction(
                title: "alert_cancel".localized,
                style: UIAlertActionStyle.cancel,
                handler: nil
            )
        )
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeLanguage(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "alert_change_language_title".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        func addActionLanguage(language: Language) {
            alert.addAction(
                UIAlertAction(
                    title: language.rawValue.localized,
                    style: UIAlertActionStyle.default,
                    handler: { _ in
                        Language.language = language
                        self.setupUI()
                })
            )
        }
        addActionLanguage(language: Language.english)
        addActionLanguage(language: Language.danish)
        addActionLanguage(language: Language.german)
        addActionLanguage(language: Language.arabic)
        
        alert.addAction(
            UIAlertAction(
                title: "alert_cancel".localized,
                style: UIAlertActionStyle.cancel,
                handler: nil
            )
        )
        present(alert, animated: true, completion: nil)
    }
    private func setupUI() {
        tabBarController?.viewControllers![0].title = "Explore".localized
        tabBarController?.viewControllers![1].title = "Quiz".localized
        tabBarController?.viewControllers![2].title = "Options".localized
        currentLanguageLabel.text = "main_page_language".localized
        flag.image = "flag".localizedImage
        languagebtn.setTitle(
            "main_page_change_language".localized,
            for: .normal
        )
        themebtn.setTitle("main_page_change_theme".localized, for: .normal)
        CurrentThemeLabel.text = "main_page_current_theme".localized + ": " +  Theme.theme.rawValue.localized
    }
}
