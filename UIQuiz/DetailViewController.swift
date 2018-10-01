//
//  DetailViewController.swift
//  UIQuiz
//
//  Created by Niels Andreas Østman on 10/09/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import UIKit
import WebKit
class DetailViewController: UIViewController {
    //MARK: Properties
    var key = ""
    @IBOutlet weak var IconImage: UIImageView!
    @IBOutlet weak var TitleContent: UITextView!
    @IBOutlet weak var CategoryContent: UITextView!
    @IBOutlet weak var DescriptionContent: UITextView!
    @IBOutlet weak var LearningContent: UITextView!
    @IBOutlet weak var HazardContent: UITextView!
    @IBOutlet weak var RelatedContent: UITextView!
    
    @IBOutlet weak var TextViewContent: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _data = Theme.GetModelData()
        let modelData = _data[key]

        var image: UIImage? = UIImage(named: (modelData?.pictureName)!)
        if image == nil {
            image = UIImage(named: "DefaultImage")
        }
        if image != nil{
            self.IconImage.image = image
        }
        var list = ""
        for r in (modelData?.relatedSigns)!
        {
            list.append(r+", ")
        }
        
        let boldattribute = [ NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18) ]
        let normalattribute = [ NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15) ]
        let combination = NSMutableAttributedString()
        
        let Title = NSMutableAttributedString(string: "Title:\n", attributes: boldattribute)
        combination.append(Title)
        let TitleDisplay = NSMutableAttributedString(string: (modelData?.title ?? ""), attributes: normalattribute)
        combination.append(TitleDisplay)
        let Category = NSMutableAttributedString(string: "\n\nCategory:\n", attributes: boldattribute)
        combination.append(Category)
        let CategoryDisplay = NSMutableAttributedString(string: (modelData?.category ?? ""), attributes: normalattribute)
        combination.append(CategoryDisplay)
        let Description = NSMutableAttributedString(string: "\n\nDescription:\n", attributes: boldattribute)
        combination.append(Description)
        let DescriptionDisplay = NSMutableAttributedString(string: (modelData?.description ?? ""), attributes: normalattribute)
        combination.append(DescriptionDisplay)
        let Learning = NSMutableAttributedString(string: "\n\nIntended learning outcome:\n", attributes: boldattribute)
        combination.append(Learning)
        let LearningDisplay = NSMutableAttributedString(string: (modelData?.behaviour ?? ""), attributes: normalattribute)
        combination.append(LearningDisplay)
        let Hazard = NSMutableAttributedString(string: "\n\nHazard:\n", attributes: boldattribute)
        combination.append(Hazard)
        let HazardDisplay = NSMutableAttributedString(string: (modelData?.hazard ?? ""), attributes: normalattribute)
        combination.append(HazardDisplay)
        let Related = NSMutableAttributedString(string: "\n\nRelated signs:\n", attributes: boldattribute)
        combination.append(Related)
        let RelatedDisplay = NSMutableAttributedString(string: list, attributes: normalattribute)
        combination.append(RelatedDisplay)
        
        TextViewContent.attributedText = combination
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    
    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    */
    //MARK: Actions
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
