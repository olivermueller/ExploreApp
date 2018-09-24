//
//  DetailViewController.swift
//  UIQuiz
//
//  Created by Niels Andreas Østman on 10/09/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    var key = ""
    @IBOutlet weak var signImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let _data = Theme.GetModelData()
        let modelData = _data[key]
        titleLabel.text = modelData?.title
        descriptionTextView.text = modelData?.description
        self.signImageView.image = UIImage(named: (modelData?.pictureName)!)
        //downloadImage(from: (modelData?.pictureFileURL)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.signImageView.image = UIImage(data: data)
            }
        }
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
