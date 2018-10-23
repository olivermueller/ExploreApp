/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the object recognition view controller for the Breakfast Finder.
*/

import UIKit
import AVFoundation
import Vision
import FilesProvider

class VisionObjectRecognitionViewController: ViewController, FileProviderDelegate {
    let server: URL = URL(string: "ftp://agoodturn.dk@linux153.unoeuro.com/")!
    let username = "agoodturn.dk"
    let password = "Nxl5Q0ZUcdYEX4QK"
    
    var webdav: FTPFileProvider?
    private let context = CIContext()
    private var saveImage = false
    private var image:UIImage = UIImage()
    var correct:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.viewControllers![0].title = "Explore".localized
        tabBarController?.viewControllers![1].title = "Quiz".localized
        tabBarController?.viewControllers![2].title = "Learn".localized
        tabBarController?.viewControllers![3].title = "Options".localized
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
        session.stopRunning()
        LRSSender.sendDataToLRS(verbId: LRSSender.VerbIdSuspended, verbDisplay: "stopped", activityId: LRSSender.ObjectIdExplore, activityName: "exploring", activityDescription: "stopped exploring")
    }
    private var detectionOverlay: CALayer! = nil
    
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
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
//        for sub in previewView.subviews
//        {
//            sub.removeFromSuperview()
//        }
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds, name: topLabelObservation.identifier)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
//            let rect = CGRect(x: objectBounds.midX-100, y: objectBounds.midY+25, width: objectBounds.width, height: objectBounds.height)
//            let buttonLayer = self.createButton(rect,title: topLabelObservation.identifier.deletingPrefix("ISO_7010_"))
//            previewView.addSubview(buttonLayer)
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
        let modeldata = Theme.GetModelData()
        let data = modeldata[identifier]
        
        let formattedString = NSMutableAttributedString(string: String(format: "\(data!.title)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 12.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: data!.title.count))
        textLayer.string = formattedString
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
                        let picturename = name+UUID().uuidString+".png"
                        if let data = UIImagePNGRepresentation(self.image) {
                            let filename = self.getDocumentsDirectory().appendingPathComponent(picturename)
                            try? data.write(to: filename)
                        }
                        self.upload(picturename, saveFolder: name)
                        performSegue(withIdentifier: "objectsegue", sender: name)
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
extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
