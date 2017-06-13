//
//  PhotoViewController.swift
//  BernieApp
//
//  Created by Eleve on 13/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
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

    
    var takingPhoto = false
    
    var previousStatusBarColor:UIColor!


    override func viewDidLoad() {
        super.viewDidLoad()
        

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
        prepareCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .clear

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = self.previousStatusBarColor
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
        self.viewController = ViewController()
        self.present( self.viewController, animated: false, completion: nil)
        self.viewController.view.alpha = 0
        
        UIView.animate(withDuration: 1.5,
                       animations: {
                        self.viewController.view.alpha = 1.0
        },
                       completion: { _ in }
        )
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

}
