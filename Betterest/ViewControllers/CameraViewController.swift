//
//  CameraViewController.swift
//  FitFilter
//
//  Created by Umar Qattan on 9/2/17.
//  Copyright © 2017 Umar Qattan. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class CameraViewController: UIViewController {

    // MARK: IBOutlet UI Elements
    @IBOutlet weak var videoPreviewView: VideoPreviewView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var numberOfPhotosTakenLabel: UILabel!
    
    // Global AVCaptureSession variables and properties
    var captureSession:AVCaptureSession = AVCaptureSession()
    var capturePhotoOutput = AVCapturePhotoOutput()
    var isCaptureSessionConfigured = false // Instance property on this view controller class
   
    
    private let sessionQueue = DispatchQueue(label: "session queue",
                                             attributes: [],
                                             target: nil) // Communicate with the session and other session objects on this queue.
    
    var previewLayer:AVCaptureVideoPreviewLayer?
    var captureDevice:AVCaptureDevice?
    let videoOutput = AVCaptureVideoDataOutput()
    
    var numberOfPhotosTaken = 0
    // Shared PhotoShootAlbum
    var photoshootAlbum = PhotoShootAlbum.shared
    
    // ImagePicker
    var imagePicker:UIImagePickerController!
    
    // MARK: BEGIN UIViewController View Life Cycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
       
        
        
        if self.isCaptureSessionConfigured {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        } else {
            
            // First time: request camera access, configure capture session, and start it.
            
            self.checkCameraAuthorization({ authorized in
                
                guard authorized else {
                    print("Permission to use camera denied.")
                    return
                    
                }
                
                self.sessionQueue.async {
                    
                    self.configureCaptureSession({ success in
                        
                        guard success else { return }
                        
                        self.isCaptureSessionConfigured = true
                        self.captureSession.startRunning()
                        
                        DispatchQueue.main.async {
                            
                            
                        self.videoPreviewView.updateVideoOrientationForDeviceOrientation()
                            self.videoPreviewView.alpha = 1.0
                            self.videoPreviewView.videoPreviewLayer.videoGravity = .resizeAspectFill
                            self.captureSession.addOutput(self.videoOutput)
                                self.videoPreviewView.session = self.captureSession
                            self.imageView.contentMode = .scaleAspectFill
                            self.cameraButton.isEnabled = true
                            self.cancelButton.isHidden = true
                            self.doneButton.isHidden = true
                            
                            
                            
                        }
                    })
                }
            })
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: END UIViewController View Life Cycle Methods
    
    
    
    // MARK: BEGIN Camera Authhrization
    func checkCameraAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            
        case .authorized:
            
            // The user has previously granted access to the camera.
            
            completionHandler(true)
            
        case .notDetermined:
            
            // The user has not yet been presented with the option to grant video access so request access.
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { success in
                completionHandler(success)
            })
            
        case .denied:
            
            // The user has previously denied access.
            
            completionHandler(false)
            
        case .restricted:
            
            // The user doesn't have the authority to request access e.g. parental restriction.
            
            completionHandler(false)
            
        }
        
    }
    
    func checkPhotoLibraryUsageDescription(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        
        switch PHPhotoLibrary.authorizationStatus() {
            
        case .authorized:
            
            // The user has previously granted access to the photo library.
            
            completionHandler(true)
            
        case .notDetermined:
            
            // The user has not yet been presented with the option to grant photo library access so request access.
            
            PHPhotoLibrary.requestAuthorization({ status in
                
                completionHandler((status == .authorized))
                
            })
            
        case .denied:
            
            // The user has previously denied access.
            
            completionHandler(false)
            
        case .restricted:
            
            // The user doesn't have the authority to request access e.g. parental restriction.
            
            completionHandler(false)
            
        }
        
    }
    
    // MARK: END Camera Authhrization
    
    
    
    // MARK: BEGIN Create Camera Capture Session
    
    // Step 1: Create the capture session
    
    func createCaptureSession() {
        
        self.captureSession = AVCaptureSession()
        
    }
    
    // Step 2: Select a camera input (Front or Back)
    
    func defaultDevice() -> AVCaptureDevice {
        
        // TODO: Add double tap Gesture to switch camera
        
        if let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInDualCamera, for: AVMediaType.video, position: .back) {
            return device // use dual camera on supported devices
        } else if let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            return device // use default back facing camera, otherwise
        } else {
            fatalError("All supported devices are expected to have at least one of the queried capture devices.")
        }
    }
    
    // Step 3: Create and configure a photo capture output
    
    func configureCaptureSession(_ completionHandler: @escaping ((_ success: Bool) -> Void)) {
        
        var success = false
        defer { completionHandler(success) } // Ensure all exit paths call completion handler
        
        // Get video input for the default camera.
        let videoCaptureDevice = defaultDevice()
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            
            print("Unable to obtain video input for default camera.")
            
            return
        }
        
        // Create and configure the photo output.
        
        let capturePhotoOutput = AVCapturePhotoOutput()
        let captureVideoOutput = AVCaptureVideoDataOutput()
        captureVideoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
        
        // Make sure inputs and output can be added to session.
        
        guard self.captureSession.canAddInput(videoInput) else { return }
        
        guard self.captureSession.canAddOutput(capturePhotoOutput) else { return }
        
        
        // Configure the session
        self.captureSession.beginConfiguration()
        
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        self.captureSession.addInput(videoInput)
        
        self.captureSession.addOutput(capturePhotoOutput)
        
        self.captureSession.commitConfiguration()
        
        self.capturePhotoOutput = capturePhotoOutput
        
        success = true
        
    }
    
    
    // MARK: BEGIN Camera Capture Helper Functions
    @IBAction func capturePhoto(_ sender: UIButton) {
        
        let photoSettings = AVCapturePhotoSettings()
        
        let device = defaultDevice()
        if device.isFlashAvailable {
            photoSettings.flashMode = .off
        }
        if !photoSettings.availablePreviewPhotoPixelFormatTypes.isEmpty {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
        }
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        numberOfPhotosTaken += 1
        
        numberOfPhotosTakenLabel.text = "\(numberOfPhotosTaken)"
        
    }
    @IBAction func done(_ sender: UIButton) {
        
        // TODO: Go to the PhotoPickerViewController
        
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
       

        imageView.image = nil
    
    }
}


extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    
//    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            // we got back an error!
//            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        } else {
//            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        }
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            // TODO OPEN NEW VIEW CONTROLLER
//            let photoPickerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoPickerViewController") as! PhotoPickerViewController
//            photoPickerViewController.image = pickedImage
//            picker.pushViewController(photoPickerViewController, animated: true)
//        }
//    }
    
   
    
    
}



// MARK: BEGIN AVCapturePhotoCaptureDelegate methods

extension CameraViewController: AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            
            // Save our captured image to photos album
            
            
            photoshootAlbum.save(image: image)
            
            //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            DispatchQueue.main.async {
                // TODO: Add Filter to image
                //self.imageView.image = image
                self.cancelButton.isEnabled = true
                self.cancelButton.isHidden = false
                self.doneButton.isEnabled = true
                self.doneButton.isHidden = false
                
              
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)

        let comicEffect = CIFilter(name: "CIComicEffect")
        
        comicEffect!.setValue(cameraImage, forKey: kCIInputImageKey)
        let image = comicEffect!.value(forKey: kCIOutputImageKey)
        let filteredImage = UIImage(ciImage: comicEffect!.value(forKey: kCIOutputImageKey) as! CIImage)
        
        
        
        
        DispatchQueue.main.async {
            self.imageView.image = filteredImage
        }
        
    }
    
}
