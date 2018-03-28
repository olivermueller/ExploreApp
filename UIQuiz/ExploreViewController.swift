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
class ExploreViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate{
    @IBOutlet weak var MaxProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var MaxProgressLabel: UILabel!
    @IBOutlet weak var MidProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var MidProgressLabel: UILabel!
    @IBOutlet weak var MinProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var MinProgressLabel: UILabel!
    
    var isRunning = true
    
    
    @IBOutlet weak var subview: UIView!
    let identifierLabel: UILabel = {
        let label = UILabel()
        //label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        isRunning = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        isRunning = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let standardDefaults = UserDefaults.standard
        if standardDefaults.string(forKey: "UUID")!==""
        {
            standardDefaults.setValue(UUID().uuidString, forKey: "UUID")
        }
        
        LRSSender.UserId = standardDefaults.string(forKey: "UUID")!
        LRSSender.currentPage = LRSSender.ObjectIdMLQuiz
        LRSSender.currentActivityName = "MLQuiz"
        //LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdInitialized, verbDisplay: "Started", activityId: LRSSender.ObjectIdMLQuiz, activityName: "MLQuiz", activityDescription: "Student started app")
        // here is where we start up the camera
        // for more details visit: https://www.letsbuildthatapp.com/course_video?id=1252
        let captureSession = AVCaptureSession()
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
        
        
        //        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
        //setupIdentifierConfidenceLabel()
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
                let secondObservation = results[1]
                let thirdObservation = results[2]
                //print(firstObservation.identifier, firstObservation.confidence)
                
                DispatchQueue.main.async {
                    self.MaxProgressLabel.text = firstObservation.identifier
                    self.MidProgressLabel.text = secondObservation.identifier
                    self.MinProgressLabel.text = thirdObservation.identifier
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
        
    }
}

