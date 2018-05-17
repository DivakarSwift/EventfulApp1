//
//  CameraHelper.swift
//  Eventful
//
//  Created by Shawn Miller on 5/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraHelper: NSObject{
    //standard avcapturesession to facilitate the use of the camera
    var captureSession: AVCaptureSession?
    //avcapture device to rep the front camera
    var frontCamera: AVCaptureDevice?
    //avcapture device to rep the back camera
    var rearCamera: AVCaptureDevice?
    
    //capture device inputs,
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    //capture device outputs
    var photoOutput: AVCapturePhotoOutput?
    //capture preview that will be displayed on the view
    var previewLayer: AVCaptureVideoPreviewLayer?
    //ability to enable and disable flashmode
    //default is off
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    //prepares our capture session for use and calls a completion handler when it’s done.
    //setting a capture session consist of four steps
        // Creating a capture session
        // Obtaining and configuring the necessary capture devices.
        // Creating inputs using the capture devices.
        // Configuring a photo output object to process captured images.
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        //created boilerplate functions for performing the 4 key steps in preparing an AVCaptureSession for photo capture
        //also set up an asynchronously executing block that calls the four functions, catches any errors if necessary, and then calls the completion handler
        func createCaptureSession() {
            //creates a new AVCaptureSession and stores it in the captureSession property.
            self.captureSession = AVCaptureSession()
            
        }
        func configureCaptureDevices() throws {
        
            //1
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            
            
            let cameras = (session.devices.compactMap { $0 })
            if !cameras.isEmpty{
                
                //2
                for camera in cameras {
                    if camera.position == .front {
                        self.frontCamera = camera
                    }
                    
                    if camera.position == .back {
                        self.rearCamera = camera
                        
                        try camera.lockForConfiguration()
                        camera.focusMode = .continuousAutoFocus
                        camera.unlockForConfiguration()
                    }
                }
            }else{
                throw CameraControllerError.noCamerasAvailable
            }
            
        }
        func configureDeviceInputs() throws {
            
            //3 ensures that captureSession exists. If not, we throw an error.
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            //4 These if statements are responsible for creating the necessary capture device input to support photo capture
            //AVFoundation only allows one camera-based input per capture session at a time. Since the rear camera is traditionally the default, we attempt to create an input from it and add it to the capture session. If that fails, we fall back on the front camera. If that fails as well, we throw an error.
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
            
        }
        func configurePhotoOutput() throws {
            
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            
            captureSession.startRunning()
            
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
        
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
        
    }
    
    //will control the switching of the camera
    func switchCameras() throws {
        
        //5 ensures that we have a valid, running capture session before attempting to switch cameras. It also verifies that there is a camera that’s currently active.
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        //6  tells the capture session to begin configuration.
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {

            guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        func switchToRearCamera() throws {
            guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        //7 calls either switchToRearCamera or switchToFrontCamera, depending on which camera is currently active.
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        //8 This line commits, or saves, our capture session after configuring it.
        captureSession.commitConfiguration()
        
    }
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
}
//using this embedded type to manage the various errors we might encounter while creating a capture session:

extension CameraHelper {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}


extension CameraHelper: AVCapturePhotoCaptureDelegate {
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }

        let imageData = photo.fileDataRepresentation()
        if let image = UIImage(data: imageData!) {

            self.photoCaptureCompletionBlock?(image, nil)
        }
        
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
        
    }
    
    
}

