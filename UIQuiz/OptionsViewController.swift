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
    @IBOutlet weak var contactbtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
    }
    
    @IBAction func changeTheme(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "alert_change_theme_title".localized,
            message: nil,
            preferredStyle: .alert
        )
        
        func addActionTheme(theme: Theme) {
            alert.addAction(
                UIAlertAction(
                    title: theme.rawValue.localized,
                    style: UIAlertActionStyle.default,
                    handler: { _ in
                        Theme.theme = theme
                        self.CurrentThemeLabel.text = "main_page_current_theme".localized + ": " +  Theme.theme.rawValue.localized
                        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdChose, verbDisplay: "selected", activityId: LRSSender.ObjectIdOptions, activityName: "theme " + Theme.theme.rawValue, activityDescription: Theme.theme.rawValue)
                        //LRSSender.sendDataToLRS(verbId: LRSSender.VerbWhatIdChose, verbDisplay: "selected", activityId: LRSSender.WhereActivityIdExploreQuizApp, activityName: "explore quiz app", activityDescription: "selected theme", activityTypeId: LRSSender.TypeActivityIdCollection, categoryId: LRSSender.WhereContextIdCollectionType )
                })
            )
        }
        addActionTheme(theme: Theme.signs)
        addActionTheme(theme: Theme.augmentedsigns)
        addActionTheme(theme: Theme.normalsigns)
        
        alert.addAction(
            UIAlertAction(
                title: "alert_cancel".localized,
                style: UIAlertActionStyle.cancel,
                handler: nil
            )
        )
        
//        if let popovercontroller = alert.popoverPresentationController{
//            popovercontroller.sourceView = self.view
//            popovercontroller.sourceRect = CGRect(x:self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
//        }
        
        present(alert, animated: true, completion: nil)
    }
    @IBAction func ChangeInfo(_ sender: Any) {
        let standardDefaults = UserDefaults.standard
        let alert = UIAlertController(title: "main_page_contact_info".localized, message: "main_page_name_email".localized, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "main_page_name".localized
            textField.text = standardDefaults.string(forKey: "Name")
            textField.keyboardType = UIKeyboardType.namePhonePad
            textField.addTarget(self, action:  #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "main_page_email".localized
            textField.text = standardDefaults.string(forKey: "Email")
            textField.keyboardType = UIKeyboardType.emailAddress
            textField.addTarget(self, action:  #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })
        let addAction = UIAlertAction(title: "alert_okay".localized, style: UIAlertActionStyle.default, handler: { _ in
            let name = alert.textFields![0]
            let email = alert.textFields![1]
            standardDefaults.setValue(name.text!, forKey: "Name")
            standardDefaults.setValue(email.text!, forKey: "Email")
            LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdRegistered, verbDisplay: "completed", activityId: LRSSender.ObjectIdWebpage, activityName: "registration form", activityDescription: "Webpage registration")
            //LRSSender.sendDataToLRS(verbId: LRSSender.VerbWhatIdAltered, verbDisplay: "altered", activityId: LRSSender.WhereActivityIdExploreQuizApp, activityName: "Explore quiz app", activityDescription: "explore quiz app registration", activityTypeId: LRSSender.TypeActivityIdUserProfile)
        })
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "alert_cancel".localized, style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func alertTextFieldDidChange(_ textField: UITextField) {
        let alertController:UIAlertController = self.presentedViewController as! UIAlertController;
        let nameTextField :UITextField  = alertController.textFields![0];
        let emailTextField :UITextField  = alertController.textFields![1];
        let addAction: UIAlertAction = alertController.actions[0];
        addAction.isEnabled = (nameTextField.text?.count)! >= 2 && isValidEmail(testStr: emailTextField.text!);
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    @IBAction func changeLanguage(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "alert_change_language_title".localized,
            message: nil,
            preferredStyle: .alert
        )
        
        func addActionLanguage(language: Language) {
            alert.addAction(
                UIAlertAction(
                    title: language.rawValue.localized,
                    style: UIAlertActionStyle.default,
                    handler: { _ in
                        Language.language = language
                        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdChose, verbDisplay: "selected", activityId: LRSSender.ObjectIdCategory, activityName: "language " + language.rawValue.localized, activityDescription: language.rawValue.localized)
                        //LRSSender.sendDataToLRS(verbId: LRSSender.VerbWhatIdChose, verbDisplay: "selected", activityId: LRSSender.WhereActivityIdExploreQuizApp, activityName: "explore quiz app", activityDescription: "selected language", activityTypeId: LRSSender.TypeActivityIdCategory, categoryId: LRSSender.WhereContextIdCollectionType )
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
        tabBarController?.viewControllers![2].title = "Learn".localized
        tabBarController?.viewControllers![3].title = "Options".localized
        currentLanguageLabel.text = "main_page_language".localized
        flag.image = "flag".localizedImage
        languagebtn.setTitle(
            "main_page_change_language".localized,
            for: .normal
        )
        themebtn.setTitle("main_page_change_theme".localized, for: .normal)
        contactbtn.setTitle("main_page_change_contact".localized, for: .normal)
        CurrentThemeLabel.text = "main_page_current_theme".localized + ": " +  Theme.theme.rawValue.localized
    }
    override func viewDidAppear(_ animated: Bool) {
        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdResumed, verbDisplay: "started", activityId: LRSSender.ObjectIdMLQuiz, activityName: "options", activityDescription: "started options")
    }
    override func viewDidDisappear(_ animated: Bool) {
        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdSuspended, verbDisplay: "stopped", activityId: LRSSender.ObjectIdMLQuiz, activityName: "options", activityDescription: "stopped options")
    }
}
