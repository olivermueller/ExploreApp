/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Contains the view controller for the Breakfast Finder.
 */

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //minimum size for the overlay boxes; if they are too small, the user cannot read the text omn the box
    let MAX_BOUNDS = 125

    
    public var detectionOverlay: CALayer! = nil

    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    
    @IBOutlet weak public var previewView: UIView!
    public let session = AVCaptureSession()
    public var requests = [VNRequest]()
    
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func clampBounds(bounds: CGRect, minBounds: CGFloat)->CGRect
    {
        var bound = bounds; //= CGRect(x: bounds.midX, y: bounds.midY, width: bounds.height, height: bounds.width)
        if bounds.width < minBounds || bounds.height < minBounds
        {
            bound = CGRect(x: bounds.midX, y: bounds.midY, width: CGFloat(MAX_BOUNDS), height: CGFloat(MAX_BOUNDS))
        }
        else if bounds.width < bounds.height
        {
            bound = CGRect(x: bounds.midX, y: bounds.midY, width: bounds.width, height: bounds.width)
        }
        else if bounds.width > bounds.height
        {
            bound = CGRect(x: bounds.midX, y: bounds.midY, width: bounds.height, height: bounds.height)
        }
        return bound
    }
    
    func createImageSubLayerInBounds(_ bounds: CGRect, position: CGPoint ,imageName: String,layerName: String) -> CALayer {
        let imagelayer = CALayer()
        imagelayer.name = layerName
        let myImage = UIImage(named: imageName)?.cgImage
        imagelayer.contents = myImage
        
        imagelayer.bounds = bounds
        imagelayer.position = position
        imagelayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        //imagelayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        
        return imagelayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect, name:String) -> CALayer{
        let shapeLayer = CALayer()
        shapeLayer.name = name
        // var bound = bounds
        var bound = CGRect(x: bounds.midX, y: bounds.midY, width: bounds.height, height: bounds.width)
        if bounds.width < CGFloat(self.MAX_BOUNDS) || bounds.height < CGFloat(self.MAX_BOUNDS)
        {
            bound = CGRect(x: bounds.midX, y: bounds.midY, width: CGFloat(self.MAX_BOUNDS), height: CGFloat(self.MAX_BOUNDS))
        }
        else if bounds.width < bounds.height
        {
            bound = CGRect(x: bounds.midX, y: bounds.midY, width: bounds.width, height: bounds.width)
        }
        else if bounds.width > bounds.height
        {
            bound = CGRect(x: bounds.midX, y: bounds.midY, width: bounds.height, height: bounds.height)
        }
        shapeLayer.bounds = bound
        shapeLayer.position = CGPoint(x: bound.midX - bound.width/2, y: (bufferSize.height - bound.midY))
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.78, 0.78, 0.8, 0.4])
        shapeLayer.cornerRadius = 7
        
        //imagelayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        
        return shapeLayer
    }
    
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Model image size is smaller.

        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.frame
        rootLayer.addSublayer(previewLayer)
        
        setupLayers()
        //updateLayerGeometry()
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
    
    //override for custom drawing behaviour
    func drawVisionRequestResults(_ results: [Any])
    {
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            else {
                return
        }
        connection.videoOrientation = .portrait
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(requests)
        } catch {
            print(error)
        }
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}

