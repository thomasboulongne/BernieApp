//
//  PhotoViewController.swift
//  BernieApp
//
//  Created by Eleve on 13/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
//    var takenPhoto: UIImage?
//    var imageView:UIImageView!
    
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice!
    var previewLayer:AVCaptureVideoPreviewLayer!


    var cameraView: UIView!
    var takenPhotoView: TakenPhotoView!
    
    var takePhotoButton: TakePhotoButton!
    var toggleFlashButton: IconRoundButton!
    var closeButton: IconRoundButton!

    var viewController: ViewController!

    var tempImgPath: URL!
    
    var takingPhoto = false
    
    var previousStatusBarColor:UIColor!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("photoviewcontroller loaded")
        //store previous status bar color in order to reset it after
        
        self.previousStatusBarColor = UIApplication.shared.statusBarView?.backgroundColor
        
        self.cameraView = UIView(frame: self.view.bounds)
        self.view.addSubview(self.cameraView)
        
        let size: CGFloat = CGFloat(takePhotoButtonHeight)
        self.takePhotoButton = TakePhotoButton(frame: CGRect(
            x: self.view.frame.width / 2 - size / 2,
            y: self.view.frame.height - size * 2,
            width: size,
            height: size))
        self.takePhotoButton.addTarget(self, action:#selector(self.takePhotoAction), for: .touchUpInside)
        self.view.addSubview(self.takePhotoButton)

        let optionSize: CGFloat = CGFloat(optionalButtonHeight)

        self.toggleFlashButton = IconRoundButton(frame: CGRect(
            x: 20,
            y: self.view.frame.height - optionSize * 2,
            width: optionSize,
            height: optionSize), iconName: "flash")
        self.toggleFlashButton.addTarget(self, action:#selector(self.toggleFlash), for: .touchUpInside)
        self.view.addSubview(self.toggleFlashButton)
        
        let closeSize: CGFloat = CGFloat(closeButtonHeight)
        self.closeButton = IconRoundButton(frame: CGRect(
            x: self.view.frame.width - closeSize * 1.5,
            y: closeSize,
            width: closeSize,
            height: closeSize), iconName: "close")
        self.closeButton.addTarget(self, action:#selector(self.close), for: .touchUpInside)
        self.closeButton.layer.borderWidth = 1
        self.closeButton.layer.borderColor = UIColor.white.cgColor
        self.view.addSubview(self.closeButton)
        
//        if let availableImage = takenPhoto {
//            imageView.image = availableImage
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
        UIApplication.shared.statusBarView?.backgroundColor = .clear
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = self.previousStatusBarColor
        UIApplication.shared.statusBarStyle = .default

    }
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
            captureDevice = availableDevices.first
            beginSession()
        }
    }
    
    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice )
            captureSession.addInput(captureDeviceInput)
        }catch {
            print( error.localizedDescription )
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            self.previewLayer = previewLayer
            self.previewLayer.frame = self.cameraView.bounds
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait

            self.cameraView.layer.addSublayer(self.previewLayer)
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value: kCVPixelFormatType_32BGRA)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.bernie.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
    }
    
    func toggleFlash() {
        var device : AVCaptureDevice!
        
        if #available(iOS 10.0, *) {
            let videoDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDuoCamera], mediaType: AVMediaTypeVideo, position: .unspecified)!
            let devices = videoDeviceDiscoverySession.devices!
            device = devices.first!
            
        } else {
            // Fallback on earlier versions
            device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        }
        
        if ((device as AnyObject).hasMediaType(AVMediaTypeVideo))
        {
            if (device.hasTorch)
            {
                captureSession.beginConfiguration()
                //self.objOverlayView.disableCenterCameraBtn();
                if device.isTorchActive == false {
                    self.flashOn(device: device)
                } else {
                    self.flashOff(device: device);
                }
                self.toggleFlashButton.isSelected = !self.toggleFlashButton.isSelected
                //self.objOverlayView.enableCenterCameraBtn();
                captureSession.commitConfiguration()
            }
        }
    }
    
    func takePhotoAction() {
        print("LOL")
        takingPhoto = true
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if takingPhoto {
            takingPhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                DispatchQueue.main.async {
                    // let photoVC
                    print(image)
                    self.takenPhotoView = TakenPhotoView(frame: self.view.bounds )
                    self.takenPhotoView.addImage(image: image)
                    self.storeTempImage(image: image)
                    self.view.addSubview(self.takenPhotoView)
                    //self.view.bringSubview(toFront: self.takenPhotoView)
                    self.view.bringSubview(toFront: self.closeButton)
                    
                }
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x:0, y:0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            print(imageRect)
            print(UIScreen.main.scale)
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopCaptureSession() {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
    
    func close()   {
        print("close")
        
        self.dismiss( animated: true, completion: {
            self.stopCaptureSession()
        })
    }
    
    
    // TO REVIEW
    private func flashOn(device:AVCaptureDevice)
    {
        do{
            if (device.hasTorch)
            {
                try device.lockForConfiguration()
                device.torchMode = .on
                device.flashMode = .on
                device.unlockForConfiguration()
            }
        }catch{
            //DISABEL FLASH BUTTON HERE IF ERROR
            print("Device tourch Flash Error ");
        }
    }
    
    private func flashOff(device:AVCaptureDevice)
    {
        do{
            if (device.hasTorch){
                try device.lockForConfiguration()
                device.torchMode = .off
                device.flashMode = .off
                device.unlockForConfiguration()
            }
        }catch{
            //DISABEL FLASH BUTTON HERE IF ERROR
            print("Device tourch Flash Error ");
        }
    }
    
    
    //SEND TO SERVER
    
    func storeTempImage(image: UIImage) {
        let filename = self.getDocumentsDirectory().appendingPathComponent("copy.jpg")
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            // Save cloned image into document directory
            try? data.write(to: filename)
            self.tempImgPath = filename
            print(self.tempImgPath)
            self.takenPhotoView.sendButton.addTarget(self, action: #selector(self.sendPhotoToServer), for: .touchUpInside)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func sendPhotoToServer() {
        let image:UIImage! = self.takenPhotoView.takenImage.image
        print(image)
        let username:String = "TEST"
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
        
        let url = "https://api.imgur.com/3/upload"
        
        let parameters = [
            "image": base64Image
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let imageData = UIImageJPEGRepresentation(image, 0.8) {
                multipartFormData.append(imageData, withName: username, fileName: "\(username).png", mimeType: "image/png")
            }
            
            for (key, value) in parameters {
                multipartFormData.append((value?.data(using: .utf8))!, withName: key)
            }}, to: url, method: .post, headers: ["Authorization": "Client-ID " + IMGUR_CLIENT_ID],
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.response { response in
                            //This is what you have been missing
                            let json = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                            let imageDict = json?["data"] as? [String:Any]
                            var query = Dictionary<String, Any>()
                            query["type"] = 3
                            query["imageUrl"] = imageDict?["link"]
                            MessageManager.shared.request(query: query)
                            self.close()
                        }
                    case .failure(let encodingError):
                        print("error:\(encodingError)")
                    }
        })
        
    }

}
