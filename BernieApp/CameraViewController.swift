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

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var captureSession : AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!
    var settings : AVCapturePhotoSettings!
    
    var device:AVCaptureDevice!
    var previewLayer:AVCaptureVideoPreviewLayer!


    var cameraView: UIView!
    var takenPhotoView: TakenPhotoView!
    
    var takePhotoButton: TakePhotoButton!
    var toggleFlashButton: IconRoundButton!
    var closeButton: IconRoundButton!

    var viewController: ViewController!

    var tempImgPath: URL!
    
    var activateFlash = false
    
    var previousStatusBarColor:UIColor!
    
    var logo: Logo!
    
    var disclaimer: UILabel!
    
    var blurEffectView : UIVisualEffectView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //store previous status bar color in order to reset it after
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        prepareCamera()
        UIApplication.shared.statusBarView?.backgroundColor = .clear
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = self.previousStatusBarColor
        UIApplication.shared.statusBarStyle = .default

    }
    
    func setupUI() {

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
            y: self.view.frame.height - size * 2 + optionSize,
            width: optionSize,
            height: optionSize), iconName: "flash")
        self.toggleFlashButton.addTarget(self, action:#selector(self.toggleFlash), for: .touchUpInside)
        self.toggleFlashButton.layer.borderColor = UIColor.white.cgColor
        
        if activateFlash {
            self.toggleFlashButton.tintColor = UIColor.yellow
        }
        
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
        
        self.takenPhotoView = TakenPhotoView(frame: self.cameraView.bounds )
        self.view.addSubview(self.takenPhotoView)
        
        self.logo = Logo(frame: CGRect(
            x: 25.0 - logoPadding,
            y: 60.0,
            width: logoSize + logoPadding * 2,
            height: logoSize + logoPadding * 2)
        )
         self.view.addSubview(self.logo)
        
        
        self.disclaimer = UILabel(frame: CGRect(
            x: 25.0,
            y: 60 + self.logo.bounds.height,
            width: self.view.frame.width - hMargin * 2,
            height: 44.0))
        self.disclaimer.font = UIFont.brnH4Font()
        self.disclaimer.textColor = UIColor.brnWhite
        self.disclaimer.numberOfLines = 0
        view.addSubview(self.disclaimer)
        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        self.blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurEffectView.frame = view.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(self.blurEffectView)
    }
    
    //  ---------------------------------------- prepare Camera ----------------------------------------
    
    func prepareCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        self.cameraOutput = AVCapturePhotoOutput()
        
        self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            try self.device.lockForConfiguration()
                self.device.focusMode = .continuousAutoFocus
                self.device.unlockForConfiguration()
        } catch {
            print("Device focus error");
        }
        
        
        if let input = try? AVCaptureDeviceInput(device: self.device) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(self.cameraOutput)) {
                    captureSession.addOutput(self.cameraOutput)
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    self.previewLayer.frame = self.cameraView.bounds
                    
                    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                    self.cameraView.layer.addSublayer(self.previewLayer)
                    captureSession.startRunning()
                    UIView.animate(withDuration: 0.5,
                                   delay: 0.3,
                                   options: UIViewAnimationOptions.curveEaseOut,
                                   animations: { () -> Void in
                                    self.blurEffectView.alpha = 0
                    }, completion: { (finished) -> Void in
                        self.blurEffectView.removeFromSuperview()
                        self.disclaimer.animate(newText: "Pas de chaton mignon, sinon je fond...", characterDelay: 0.03)
                        self.logo.play(file: "Humeur4-Chill")
                    })
                    
                }
            } else {
                print("issue here : captureSession.canAddInput")
            }
        } else {
            print("some problem here")
        }
        
        
    }
    
     //  -------------------------------------- takePhotoAction ---------------------------------------
    
    func takePhotoAction() {
        self.settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        self.settings.previewPhotoFormat = previewFormat
        if self.activateFlash == true {
            self.settings.flashMode = .on
        } else {
            self.settings.flashMode = .off
            
        }
        
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            self.takenPhotoView.addImage(image: image)
            self.storeTempImage(image: image)
            self.view.bringSubview(toFront: self.closeButton)
            
            self.disclaimer.animate(newText: "Envoie la moi, voir si je trouve !", characterDelay: 0.03)
            self.logo.play(file: "Humeur2-Search")

        } else {
            print("Error, capture photo didn't work")
        }
        
    }
    
    func toggleFlash() {
        var device : AVCaptureDevice!
        device = self.device
        
        if ((device as AnyObject).hasMediaType(AVMediaTypeVideo))
        {
            if (device.hasTorch)
            {
                captureSession.beginConfiguration()
                //self.objOverlayView.disableCenterCameraBtn();
                if self.activateFlash == false {
                    self.activateFlash = true
                    self.toggleFlashButton.tintColor = UIColor.yellow
                } else {
                    self.activateFlash = false
                    self.toggleFlashButton.tintColor = UIColor.white
                }
                
                if activateFlash {
                }
                self.toggleFlashButton.isSelected = !self.toggleFlashButton.isSelected
                //self.objOverlayView.enableCenterCameraBtn();
                captureSession.commitConfiguration()
            }
        }
    }
    
    func stopCaptureSession() {
        self.captureSession.stopRunning()
    }
    
    func close()   {
        
        self.dismiss( animated: true, completion: {
            self.takenPhotoView.isHidden = true
            self.stopCaptureSession()
        })
    }
    
    
    // --------------------------------- SEND TO SERVER  ---------------------------------
    
    func storeTempImage(image: UIImage) {
        let filename = self.getDocumentsDirectory().appendingPathComponent("copy.jpg")
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            // Save cloned image into document directory
            try? data.write(to: filename)
            self.tempImgPath = filename
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
                            query["imageUrl"] = (imageDict?["link"] as! String).replacingOccurrences(of: "http:", with: "https:")
                            MessageManager.shared.request(query: query)
                            self.close()
                        }
                    case .failure(let encodingError):
                        print("error:\(encodingError)")
                    }
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
