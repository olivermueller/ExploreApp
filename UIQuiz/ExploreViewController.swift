//
//  FirstViewController.swift
//  UIQuiz
//
//  Created by Niels Østman on 09/03/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import AVKit
import Vision
import os.log
class ExploreViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate{
    @IBOutlet weak var MaxProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var MaxProgressLabel: UILabel!
    @IBOutlet weak var MidProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var MidProgressLabel: UILabel!
    @IBOutlet weak var MinProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var MinProgressLabel: UILabel!
    
    var captureSession:AVCaptureSession!
    var isRunning = true
    var labels:[ModelDataContainer] = [ModelDataContainer]()
    var labelsDict: [String: ModelDataContainer] = [:]
    var results: [VNClassificationObservation]?
    
    @IBOutlet weak var subview: UIView!
    let identifierLabel: UILabel = {
        let label = UILabel()
        //label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        print("Explore view appeared")
        if isRunning
        {
            captureSession.startRunning()
        }
        isRunning = true
        let standardDefaults = UserDefaults.standard
        if standardDefaults.string(forKey: "Name")==""||standardDefaults.string(forKey: "Email")=="'"
        {
            let alert = UIAlertController(title: "Contact information", message: "Please enter your name and e-mail", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter name"
                textField.keyboardType = UIKeyboardType.namePhonePad
                textField.addTarget(self, action:  #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
            })
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter e-mail address"
                textField.keyboardType = UIKeyboardType.emailAddress
                textField.addTarget(self, action:  #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
            })
            let addAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { _ in
                let name = alert.textFields![0]
                let email = alert.textFields![1]
                standardDefaults.setValue(name.text!, forKey: "Name")
                standardDefaults.setValue(email.text!, forKey: "Email")
                LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdRegistered, verbDisplay: "completed", activityId: LRSSender.ObjectIdWebpage, activityName: "registration form", activityDescription: "Webpage registration")
                LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdResumed, verbDisplay: "started", activityId: LRSSender.ObjectIdExplore, activityName: "exploring", activityDescription: "started exploring")
                //LRSSender.sendDataToLRS(verbId: LRSSender.VerbWhatIdRegistered, verbDisplay: "registered", activityId: LRSSender.WhereActivityIdExploreQuizApp, activityName: "Explore quiz app", activityDescription: "explore quiz app registration", activityTypeId: LRSSender.TypeActivityIdUserProfile)
            })
            addAction.isEnabled = false
            alert.addAction(addAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        else{
            LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdResumed, verbDisplay: "started", activityId: LRSSender.ObjectIdExplore, activityName: "exploring", activityDescription: "started exploring")
        }
        
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
    override func viewDidDisappear(_ animated: Bool) {
        print("Explore view disappeared")
        captureSession.stopRunning()
        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdSuspended, verbDisplay: "stopped", activityId: LRSSender.ObjectIdExplore, activityName: "exploring", activityDescription: "stopped exploring")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let standardDefaults = UserDefaults.standard
       
        
        LRSSender.UserId = standardDefaults.string(forKey: "UUID")!
        LRSSender.currentPage = LRSSender.ObjectIdMLQuiz
        LRSSender.currentActivityName = "MLQuiz"
        //LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdInitialized, verbDisplay: "Started", activityId: LRSSender.ObjectIdMLQuiz, activityName: "MLQuiz", activityDescription: "Student started app")
        setupAV()
        tabBarController?.viewControllers![0].title = "Explore".localized
        tabBarController?.viewControllers![1].title = "Quiz".localized
        tabBarController?.viewControllers![2].title = "Learn".localized
        tabBarController?.viewControllers![3].title = "Options".localized
    }
    private func setupAV(){
        captureSession = AVCaptureSession()
        //captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        subview.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //        print("Camera was able to capture a frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        
        
        // !!!Important
        // make sure to go download the models at https://developer.apple.com/machine-learning/ scroll to the bottom
        //guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else { return }
        let model = Theme.GetModel()
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            //perhaps check the err
            
            //            print(finishedReq.results)
            
            self.results = finishedReq.results as? [VNClassificationObservation]
            if self.results == nil {return}
//            if self.labels.count==0{
//                for result in self.results! {
//                    self.labels.append(ModelDataContainer(key: result.identifier, description: "This is the description", correctAnswerDescription: "correct", wrongAnswerDescription: "wrong", title: "title", pictureName: "ISO_7010_E001", coreDescription: "core", optional: "optional", type: sign_type.Fire_Protection))
//                }
//            }
            
            guard let firstObservation = self.results?.first else { return }
            let secondObservation = self.results![1]
            let thirdObservation = self.results![2]
            //print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.MaxProgressLabel.text = firstObservation.identifier.localized
                self.MidProgressLabel.text = secondObservation.identifier.localized
                self.MinProgressLabel.text = thirdObservation.identifier.localized
                //self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
                UIView.animate(withDuration: 0.2) {
                    self.MaxProgressBar.value = CGFloat(firstObservation.confidence * 100)
                    self.MidProgressBar.value = CGFloat(secondObservation.confidence * 100)
                    self.MinProgressBar.value = CGFloat(thirdObservation.confidence * 100)
                }
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "detailSegue1":
            os_log("detail segue", log: OSLog.default, type: .debug)
            let destinationNavigationController = segue.destination as! UINavigationController
            guard let detailViewController = destinationNavigationController.topViewController as? DetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            detailViewController.key = self.results![0].identifier
        case "detailSegue2":
            os_log("detail segue", log: OSLog.default, type: .debug)
            let destinationNavigationController = segue.destination as! UINavigationController
            guard let detailViewController = destinationNavigationController.topViewController as? DetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            detailViewController.key = self.results![1].identifier
        case "detailSegue3":
            os_log("detail segue", log: OSLog.default, type: .debug)
            let destinationNavigationController = segue.destination as! UINavigationController
            guard let detailViewController = destinationNavigationController.topViewController as? DetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            detailViewController.key = self.results![2].identifier
        default:
            os_log("not detail", log: OSLog.default, type: .debug)
        }
       
        
    }
    @IBAction func SaveLabels(_ sender: Any) {
        for label in labels{
            labelsDict[label.key] = label
        }

        let jsonEncoder = JSONEncoder()
        do{
            let jsondata = try jsonEncoder.encode(labelsDict)
            let json = String(data: jsondata, encoding: String.Encoding.utf8)
            print(json!)
        }
        catch{
            print("lol")
        }
//        let decoder = JSONDecoder()
//        do {
//            let products = try decoder.decode([ModelDataContainer].self, from: json)
//            print("The following products are available:")
//            for product in products {
//                print("\t\(product.keyName) (\(product.description) points)")
//            }
//        } catch {
//            print("Shit")
//        }
        
        
        
       
    }
    
}

