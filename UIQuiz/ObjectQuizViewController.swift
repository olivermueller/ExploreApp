/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Contains the object recognition view controller for the Breakfast Finder.
 */

import UIKit
import AVFoundation
import Vision
import FilesProvider

class ObjectQuizViewController: SecondViewController, FileProviderDelegate {
    
    private let context = CIContext()
    private var saveImage = false
    private var image:UIImage = UIImage()
    private var detectionOverlay: CALayer! = nil
    var correct:String = ""
    var top4 = [ModelDataContainer]()
    let server: URL = URL(string: "ftp://agoodturn.dk@linux153.unoeuro.com/")!
    let username = "agoodturn.dk"
    let password = "Nxl5Q0ZUcdYEX4QK"
    
    var webdav: FTPFileProvider?
//    var topLabelsObservation: [VNRecognizedObjectObservation] = [VNRecognizedObjectObservation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let credential = URLCredential(user: username, password: password, persistence: .permanent)
        
        //        webdav = WebDAVFileProvider(baseURL: server, credential: credential)!
        webdav = FTPFileProvider(baseURL: server, credential: credential)!
        webdav?.delegate = self as FileProviderDelegate
    }
    func upload(_ filename: String, saveFolder:String) {
        let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
        let remotePath = "/GPOCST/"+saveFolder+"/"+filename
        let progress = webdav?.copyItem(localFile: localURL, to: remotePath, completionHandler: nil)
        //        uploadProgressView.observedProgress = progress
    }
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    override func viewDidAppear(_ animated: Bool) {
        session.startRunning()
        tabBarController?.viewControllers![0].title = "Explore".localized
        tabBarController?.viewControllers![1].title = "Quiz".localized
        tabBarController?.viewControllers![2].title = "Learn".localized
        tabBarController?.viewControllers![3].title = "Options".localized
    }
    override func viewDidDisappear(_ animated: Bool) {
        session.stopRunning()
        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdSuspended, verbDisplay: "stopped", activityId: LRSSender.ObjectIdMLQuiz, activityName: "quiz mode", activityDescription: "stopped quiz mode")
    }
    // Vision parts
    private var requests = [VNRequest]()
    
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        do {
            let visionModel = Theme.GetModel()
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
//        topLabelsObservation.removeAll()
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
//            topLabelsObservation.append(objectObservation)
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds, name: topLabelObservation.identifier)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        image = imageFromSampleBuffer(sampleBuffer: sampleBuffer)!
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()
        
        // start the capture
        startCaptureSession()
    }
    
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = identifier
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier.deletingPrefix("ISO_7010_"))\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        //textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        
        return textLayer
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let point = touch.location(in: self.view)
            if let hitLayer = self.detectionOverlay.hitTest(point) {
                if let name = hitLayer.name {
                    if hitLayer != detectionOverlay{
                        QuizButtonPress(selected: name)
                    }
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavigationController = segue.destination as! UINavigationController
        guard let detailViewController = destinationNavigationController.topViewController as? DetailViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        let name = sender as! String
        print("preparing: " + name)
        detailViewController.key = name
        
        
    }
    func createRoundedRectLayerWithBounds(_ bounds: CGRect, name:String) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.name = name
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    func QuizButtonPress(selected:String) {
        print("Quiz pressed!")
        //wikiSearch()
        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdInitialized, verbDisplay: "started", activityId: LRSSender.ObjectIdMLQuiz, activityName: "quiz", activityDescription: "started quiz")
        //LRSSender.sendDataToLRS(verbId: LRSSender.VerbWhatIdAccept, verbDisplay: "clicked", activityId: LRSSender.WhereActivityIdExploreQuizApp, activityName: "explore quiz app", activityDescription: "clicked percentage", object: (self.res?[0].identifier)!, score: Float((self.res?[0].confidence)! ))
        session.stopRunning()
        var selectedSign = Theme.GetModelData()[selected]
        correct = (selectedSign?.key)!
        var signs = Theme.GetModelData().values.filter{ $0.type == selectedSign?.type && $0.key != selectedSign?.key }
        signs.shuffle()
        top4.removeAll()
        top4.append(selectedSign!)
        top4.append(signs[0])
        top4.append(signs[1])
        top4.append(signs[2])
        top4.shuffle()
        let alert = UIAlertController(
            title: "alert_select_quiz_answer".localized,
            message: nil,
            preferredStyle: .alert
        )
        
        func addActionAnswer(answer: ModelDataContainer) {
            alert.addAction(
                UIAlertAction(
                    title: answer.title.localized,
                    style: UIAlertActionStyle.default,
                    handler: { _ in
                        //Language.language = language
                        let picturename = self.correct+UUID().uuidString+".png"
                        if let data = UIImagePNGRepresentation(self.image) {
                            let filename = self.getDocumentsDirectory().appendingPathComponent(picturename)
                            try? data.write(to: filename)
                        }
                        self.upload(picturename, saveFolder: self.correct)
                        let isCorrect = (answer.key == self.correct)
                        self.alertMessage(correct: isCorrect , answer: self.correct )
                        
                        if isCorrect == true
                        {
                            LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdPassed, verbDisplay: "passed", activityId: LRSSender.ObjectIdMLQuiz, activityName: "quiz", activityDescription: "Selected: " + answer.key + " options were: " + self.top4[0].key + "; " + self.top4[1].key + "; " + self.top4[2].key + "; " + self.top4[3].key + " correct was: " + self.correct)
                        }
                        else
                        {
                            LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdFailed, verbDisplay: "failed", activityId: LRSSender.ObjectIdMLQuiz, activityName: "quiz", activityDescription: "Selected: " + answer.key + " options were: " + self.top4[0].key + "; " + self.top4[1].key + "; " + self.top4[2].key + "; " + self.top4[3].key + " correct was: " + self.correct)
                        }
                        
                        //LRSSender.sendDataToLRS(verbId: LRSSender.VerbWhatIdIdentified, verbDisplay: "selected", activityId: LRSSender.WhereActivityIdExploreQuizApp, activityName: "explore quiz app", activityDescription: "selected identifier", activityTypeId: LRSSender.TypeActivityIdItem, object: (self.res?[0].identifier)!, success: isCorrect)
                        self.session.startRunning()
                })
            )
        }
        addActionAnswer(answer: self.top4[0])
        addActionAnswer(answer: self.top4[1])
        addActionAnswer(answer: self.top4[2])
        addActionAnswer(answer: self.top4[3])
        
        alert.addAction(
            UIAlertAction(
                title: "alert_cancel".localized,
                style: UIAlertActionStyle.cancel,
                handler: { _ in
                    //Language.language = language
                    self.session.startRunning()
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
        let _data = Theme.GetModelData()
        let modelData = _data[answer]
        // create the alert
        var alert = UIAlertController(title: title, message: modelData?.imageContentDescription, preferredStyle: UIAlertControllerStyle.alert)
        if !correct{
            alert = UIAlertController(title: title, message: modelData?.imageContentDescription, preferredStyle: UIAlertControllerStyle.alert)
        }
        
        let uiImageAlertAction = UIAlertAction(title: "", style: .default, handler: nil)
        let image = UIImage(named: (modelData?.pictureName)!)
        
        // size the image
        let reSizedImage = resizeImage(image: image!, newWidth: 245)
        
        // add an action (button)
        let action = UIAlertAction(title: "alert_okay".localized, style: UIAlertActionStyle.default, handler: nil)
        
        uiImageAlertAction.setValue(reSizedImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal), forKey: "image")
        uiImageAlertAction.isEnabled = false
        alert.addAction(uiImageAlertAction)
        alert.addAction(action)
        //        alert.view.addSubview(imageView)
        
        //AudioServicesPlaySystemSound (systemSoundID!)
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("\(source) copied to \(dest).")
        case .remove(path: let path):
            print("\(path) has been deleted.")
        default:
            if let destination = operation.destination {
                print("\(operation.actionDescription) from \(operation.source) to \(destination) succeed.")
            } else {
                print("\(operation.actionDescription) on \(operation.source) succeed.")
            }
        }
    }
    
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("copying \(source) to \(dest) has been failed.")
        case .remove:
            print("file can't be deleted.")
        default:
            if let destination = operation.destination {
                print("\(operation.actionDescription) from \(operation.source) to \(destination) failed.")
            } else {
                print("\(operation.actionDescription) on \(operation.source) failed.")
            }
        }
    }
    
    func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
        switch operation {
        case .copy(source: let source, destination: let dest) where dest.hasPrefix("file://"):
            print("Downloading \(source) to \((dest as NSString).lastPathComponent): \(progress * 100) completed.")
        case .copy(source: let source, destination: let dest) where source.hasPrefix("file://"):
            print("Uploading \((source as NSString).lastPathComponent) to \(dest): \(progress * 100) completed.")
        case .copy(source: let source, destination: let dest):
            print("Copy \(source) to \(dest): \(progress * 100) completed.")
        default:
            break
        }
    }
}
