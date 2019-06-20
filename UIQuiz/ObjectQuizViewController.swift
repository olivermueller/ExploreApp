/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Contains the object recognition view controller for the Breakfast Finder.
 */

import UIKit
import AVFoundation
import Vision

class ObjectQuizViewController: ViewController {
    
    private let context = CIContext()
    private var saveImage = false
    private var image:UIImage = UIImage()

    var correct:String = ""
    var top4 = [ModelDataContainer]()

    
//    var topLabelsObservation: [VNRecognizedObjectObservation] = [VNRecognizedObjectObservation]()
    override func viewDidLoad() {
        super.viewDidLoad()
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
    var dic: [String: VisionObjectRecognitionViewController.layerInfo] = [:]

    override func drawVisionRequestResults(_ results: [Any]) {
//        topLabelsObservation.removeAll()
        /*CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        super.detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
//            topLabelsObservation.append(objectObservation)
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = super.createRoundedRectLayerWithBounds(objectBounds, name: topLabelObservation.identifier, transparency: CGFloat(objectObservation.labels[0].confidence))

            //make sure the bounds are always square
            let clampedBounds = super.clampBounds(bounds: objectBounds, minBounds: CGFloat(super.MAX_BOUNDS))
            
            //position the question mark image in the parent layer
            let questionsImageBounds = CGRect(x: clampedBounds.midX , y: clampedBounds.midY , width: clampedBounds.width, height: clampedBounds.height)
            
            let clickImagePosition = CGPoint(x: questionsImageBounds.midX - questionsImageBounds.width/2, y: questionsImageBounds.midY - questionsImageBounds.height/2)
            
            let questionImageLayer = super.createImageSubLayerInBounds(questionsImageBounds,position: clickImagePosition,imageName: "questionmark", layerName: topLabelObservation.identifier)
            
            
           // shapeLayer.addSublayer(imageLayer)
            shapeLayer.addSublayer(questionImageLayer)
            super.detectionOverlay.addSublayer(shapeLayer)
        }
        CATransaction.commit()*/
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        CATransaction.commit()
        
        /*if(results.count == 0 && detectionOverlay.sublayers != nil)
         {
         print("removing all")
         detectionOverlay.sublayers?.removeAll()
         }*/
        
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            
            // Select only the label with the highest confidence
            
            let topLabelObservation = objectObservation.labels[0]
            
            
            if(dic[objectObservation.labels[0].identifier] == nil)
            {
                var li = VisionObjectRecognitionViewController.layerInfo(layer: CALayer(), hasUpdated: false, curConfidence: objectObservation.labels[0].confidence, index: -1)
                dic[objectObservation.labels[0].identifier] = li;
            }
            else
            {
                dic[objectObservation.labels[0].identifier]?.hasUpdated = false
                dic[objectObservation.labels[0].identifier]?.curConfidence = objectObservation.labels[0].confidence
            }
            
            
            if(topLabelObservation.confidence < 0.7) {continue}
            
            
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = super.createRoundedRectLayerWithBounds(objectBounds, name: topLabelObservation.identifier, transparency: CGFloat(objectObservation.labels[0].confidence))
            
            //make sure the bounds are always square
            let clampedBounds = super.clampBounds(bounds: objectBounds, minBounds: CGFloat(super.MAX_BOUNDS))
            
            //position the question mark image in the parent layer
            let questionsImageBounds = CGRect(x: clampedBounds.midX , y: clampedBounds.midY , width: clampedBounds.width, height: clampedBounds.height)
            
            let clickImagePosition = CGPoint(x: questionsImageBounds.midX - questionsImageBounds.width/2, y: questionsImageBounds.midY - questionsImageBounds.height/2)
            
            
            var skipLayer = false;
            detectionOverlay.sublayers?.forEach {
                
                //makes sure there are never two predictions overlapping
                /*if($0.bounds.intersects(shapeLayer.bounds))
                 {
                 skipLayer = true
                 }*/
                
                if($0.name == shapeLayer.name)
                {
                    $0.bounds = shapeLayer.bounds
                    var newPos = shapeLayer.position
                    
                    var animationWait = 1.0/CGFloat(ViewController.WAIT_FRAMES) - 0.1;
                    if (animationWait < 0){animationWait = 0}
                    super.animatePositionAsync(layer: $0, toPosition: newPos, animationTime: animationWait)
                    //dic[shapeLayer.name!]?.layer = shapeLayer
                    dic[shapeLayer.name!]?.hasUpdated = true
                    let clampedBounds = super.clampBounds(bounds: shapeLayer.bounds, minBounds: CGFloat(super.MAX_BOUNDS))
                    
                    dic[shapeLayer.name!]?.layer.sublayers![0].position = clickImagePosition
                    dic[shapeLayer.name!]?.layer.sublayers![0].bounds = questionsImageBounds
                    //dic[shapeLayer.name!]?.layer.sublayers![2].bounds = textLayerBounds
                    //$0.position = newPos
                    skipLayer = true
                }
                else{
                    
                }
                
            }
            
            //print("adding layer")
            if(skipLayer) {continue}
            
            
            
            let questionImageLayer = super.createImageSubLayerInBounds(questionsImageBounds,position: clickImagePosition,imageName: "questionmark", layerName: topLabelObservation.identifier)

            
            shapeLayer.addSublayer(questionImageLayer)
            
            detectionOverlay.addSublayer(shapeLayer)
            dic[shapeLayer.name!]?.layer =  shapeLayer
            dic[shapeLayer.name!]?.hasUpdated = true
        }
        for(k, v) in dic{
            if(v.hasUpdated == true)
            {
                //detectionOverlay.addSublayer(v.layer);
            }
            else if(dic[k]?.layer.superlayer != nil)
            {
                print("removing")
                dic[k]?.layer.removeFromSuperlayer()
            }
            dic[k]?.hasUpdated = false
        }
        CATransaction.commit()
        
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let point = touch.location(in: self.view)
            if let hitLayer = super.detectionOverlay.hitTest(point) {
                if let name = hitLayer.name {
                    if hitLayer != super.detectionOverlay{
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
}
