/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the object recognition view controller for the Breakfast Finder.
*/

import UIKit
import AVFoundation
import Vision
import Foundation
import Accelerate
import CoreImage

extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}
class VisionObjectRecognitionViewController: ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.viewControllers![0].title = "Explore".localized
        tabBarController?.viewControllers![1].title = "Quiz".localized
        tabBarController?.viewControllers![2].title = "Learn".localized
        tabBarController?.viewControllers![3].title = "Options".localized
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
    
    // Vision parts
    
    override func drawVisionRequestResults(_ results: [Any]) {
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
            // Select only the label with the highest and decent confidence
            if(objectObservation.labels[0].confidence < 0.7) {continue}
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = super.createRoundedRectLayerWithBounds(objectBounds, name: topLabelObservation.identifier + "_sublayer", transparency: CGFloat(objectObservation.labels[0].confidence))
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            var k = false;
            detectionOverlay.sublayers?.forEach {
                
                if($0.bounds.intersects(shapeLayer.bounds))
                {
                    k = true
                }
                
            }
            
            if(k) {continue}
           //make sure the bounds are always square
            let clampedBounds = super.clampBounds(bounds: objectBounds, minBounds: CGFloat(super.MAX_BOUNDS))
            
            //position the click image in the parent layer
            let clickImageBounds = CGRect(x: clampedBounds.midX , y: clampedBounds.midY , width: clampedBounds.width/4, height: clampedBounds.height/4)
            
            let clickImagePosition = CGPoint(x: clickImageBounds.midX + clickImageBounds.width, y: clickImageBounds.midY + clickImageBounds.height)
            
            let imageLayer = super.createImageSubLayerInBounds(clickImageBounds,position: clickImagePosition,imageName: "click", layerName: topLabelObservation.identifier)
            
            //position sign image in the parent layer
            let signImageBounds = CGRect(x: clampedBounds.midX , y: clampedBounds.midY , width: clampedBounds.width/2, height: clampedBounds.height/2)
            
            let signImagePosition = CGPoint(x: signImageBounds.midX - signImageBounds.width, y: signImageBounds.midY - signImageBounds.width)
            
            let imageQuestionLayer = super.createImageSubLayerInBounds(signImageBounds, position: signImagePosition, imageName: topLabelObservation.identifier, layerName: topLabelObservation.identifier)

            shapeLayer.addSublayer(imageLayer)
            shapeLayer.addSublayer(imageQuestionLayer)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
            
            //makes sure there are never two of the same predictions on the screen
            
        }
        CATransaction.commit()
    }
    
    
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = identifier
        let modeldata = Theme.GetModelData()
        let data = modeldata[identifier]
        
        let formattedString = NSMutableAttributedString(string: String(format: "\(data!.title)\n"+"Confidence".localized+":  %.2f", confidence).uppercased())
        let largeFont = UIFont(name: "Helvetica", size: 12.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: data!.title.count))
        textLayer.string = formattedString
        
        var bound = clampBounds(bounds: bounds, minBounds: CGFloat(MAX_BOUNDS))
        textLayer.bounds = CGRect(x: -10, y: -(bound.height/4), width: bound.width, height: bound.height/2)
        textLayer.position = CGPoint(x: bound.midX, y: bound.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        
        return textLayer
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let point = touch.location(in: self.view)
            if let hitLayer = self.detectionOverlay.hitTest(point) {
                if let name = hitLayer.name {
                    if hitLayer != detectionOverlay{
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
    
}
extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
