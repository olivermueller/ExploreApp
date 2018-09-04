//
//  SecondViewController.swift
//  UIQuiz
//
//  Created by Niels Østman on 09/03/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import AVKit
import Vision
import AVFoundation
import WikipediaKit

class QuizViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var MaxProgressBar: MBCircularProgressBarView!
    var isRunning = true
    var captureSession:AVCaptureSession!
    var res:[VNClassificationObservation]?
    @IBOutlet weak var subview: UIView!
    
    @IBOutlet weak var imagewiki: UIImageView!
    @IBOutlet weak var wikiview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAV()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func wikiSearch(){
        WikipediaNetworking.appAuthorEmailForAPI = "nies@itu.dk"
        let language = WikipediaLanguage("en")
        
        let _ = Wikipedia.shared.requestOptimizedSearchResults(language: language, term: (self.res?[0].identifier.localized)!) { (searchResults, error) in
            
            guard error == nil else { return }
            guard let searchResults = searchResults else { return }
            self.wikiview.text = searchResults.results[0].displayText
            self.downloadImage(from: searchResults.results[0].imageURL!)
        }
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
                self.imagewiki.image = UIImage(data: data)
            }
        }
    }
    @IBAction func QuizButtonPress(_ sender: Any) {
        print("Quiz pressed!")
        //wikiSearch()
        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdInitialized, verbDisplay: "started", activityId: LRSSender.ObjectIdMLQuiz, activityName: "quiz", activityDescription: "started quiz")
        //LRSSender.sendDataToLRS(verbId: LRSSender.VerbWhatIdAccept, verbDisplay: "clicked", activityId: LRSSender.WhereActivityIdExploreQuizApp, activityName: "explore quiz app", activityDescription: "clicked percentage", object: (self.res?[0].identifier)!, score: Float((self.res?[0].confidence)! ))
        captureSession.stopRunning()
        let alert = UIAlertController(
            title: "alert_select_quiz_answer".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        func addActionAnswer(answer: String) {
            alert.addAction(
                UIAlertAction(
                    title: answer.localized,
                    style: UIAlertActionStyle.default,
                    handler: { _ in
                        //Language.language = language
                        let isCorrect = (answer == self.res?[0].identifier)
                        self.alertMessage(correct: isCorrect , answer: answer)
                        
                        if isCorrect == true
                        {
                            LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdPassed, verbDisplay: "passed", activityId: LRSSender.ObjectIdMLQuiz, activityName: "quiz", activityDescription: "Selected: " + answer + " options were: " + (self.res?[0].identifier)! + "; " + (self.res?[1].identifier)! + "; " + (self.res?[2].identifier)! + "; " + (self.res?[3].identifier)! + " correct was: " + (self.res?[0].identifier)!)
                        }
                        else
                        {
                            LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdFailed, verbDisplay: "failed", activityId: LRSSender.ObjectIdMLQuiz, activityName: "quiz", activityDescription: "Selected: " + answer + " options were: " + (self.res?[0].identifier)! + "; " + (self.res?[1].identifier)! + "; " + (self.res?[2].identifier)! + "; " + (self.res?[3].identifier)! + " correct was: " + (self.res?[0].identifier)!)
                        }
 
                        //LRSSender.sendDataToLRS(verbId: LRSSender.VerbWhatIdIdentified, verbDisplay: "selected", activityId: LRSSender.WhereActivityIdExploreQuizApp, activityName: "explore quiz app", activityDescription: "selected identifier", activityTypeId: LRSSender.TypeActivityIdItem, object: (self.res?[0].identifier)!, success: isCorrect)
                        self.captureSession.startRunning()
                })
            )
        }
        addActionAnswer(answer: (res?[0].identifier)!)
        addActionAnswer(answer: (res?[1].identifier)!)
        addActionAnswer(answer: (res?[2].identifier)!)
        addActionAnswer(answer: (res?[3].identifier)!)
        
        alert.addAction(
            UIAlertAction(
                title: "alert_cancel".localized,
                style: UIAlertActionStyle.cancel,
                handler: { _ in
                    //Language.language = language
                    self.captureSession.startRunning()
            })
        )
        present(alert, animated: true, completion: nil)
        
    }
    private func alertMessage(correct: Bool, answer: String)
    {
        var systemSoundID:SystemSoundID?
        var title:String?
        if correct{
            title = "alert_correct".localized
            systemSoundID = 1325
        }
        else{
            title = "alert_incorrect".localized
            systemSoundID = 1332
        }
        // create the alert
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "alert_okay".localized, style: UIAlertActionStyle.default, handler: nil))
        
        //AudioServicesPlaySystemSound (systemSoundID!)
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        print("Quiz view appeared")
        if isRunning
        {
            captureSession.startRunning()
        }
        isRunning = true
        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdResumed, verbDisplay: "started", activityId: LRSSender.ObjectIdMLQuiz, activityName: "quiz mode", activityDescription: "started quiz mode")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("Quiz view disappeared")
        captureSession.stopRunning()
        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdSuspended, verbDisplay: "stopped", activityId: LRSSender.ObjectIdMLQuiz, activityName: "quiz mode", activityDescription: "stopped quiz mode")
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
        if isRunning
        {
            //        print("Camera was able to capture a frame:", Date())
            
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            // !!!Important
            // make sure to go download the models at https://developer.apple.com/machine-learning/ scroll to the bottom
            //guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else { return }
            let model = Theme.GetModel()
            let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
                
                //perhaps check the err
                
                //            print(finishedReq.results)
                
                guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
                
                guard let firstObservation = results.first else { return }
                //print(firstObservation.identifier, firstObservation.confidence)
                
                DispatchQueue.main.async {
                    self.res = results
                    UIView.animate(withDuration: 0.2) {
                        self.MaxProgressBar.value = CGFloat(firstObservation.confidence * 100)
                    }
                }
                
            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        }
        
    }
}

