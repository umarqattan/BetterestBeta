//
//  FilterCameraViewController.swift
//  FitFilter
//
//  Created by Umar Qattan on 9/2/17.
//  Copyright © 2017 Umar Qattan. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVFoundation
import CoreMedia


let CMYKHalftone = "CMYK Halftone"
let CMYKHalftoneFilter = CIFilter(name: "CICMYKHalftone", withInputParameters: ["inputWidth" : 20, "inputSharpness": 1])

let ComicEffect = "Comic Effect"
let ComicEffectFilter = CIFilter(name: "CIComicEffect")

let Crystallize = "Crystallize"
let CrystallizeFilter = CIFilter(name: "CICrystallize", withInputParameters: ["inputRadius" : 30])

let Edges = "Edges"
let EdgesEffectFilter = CIFilter(name: "CIEdges", withInputParameters: ["inputIntensity" : 10])

let HexagonalPixellate = "Hex Pixellate"
let HexagonalPixellateFilter = CIFilter(name: "CIHexagonalPixellate", withInputParameters: ["inputScale" : 40])

let Invert = "Invert"
let InvertFilter = CIFilter(name: "CIColorInvert")

let Pointillize = "Pointillize"
let PointillizeFilter = CIFilter(name: "CIPointillize", withInputParameters: ["inputRadius" : 30])

let LineOverlay = "Line Overlay"
let LineOverlayFilter = CIFilter(name: "CILineOverlay")

let Posterize = "Posterize"
let PosterizeFilter = CIFilter(name: "CIColorPosterize", withInputParameters: ["inputLevels" : 5])

let Filters = [
    CMYKHalftone: CMYKHalftoneFilter,
    ComicEffect: ComicEffectFilter,
    Crystallize: CrystallizeFilter,
    Edges: EdgesEffectFilter,
    HexagonalPixellate: HexagonalPixellateFilter,
    Invert: InvertFilter,
    Pointillize: PointillizeFilter,
    LineOverlay: LineOverlayFilter,
    Posterize: PosterizeFilter
]

let FilterNames = [String](Filters.keys).sorted()






class FilterCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let mainGroup = UIStackView()
    let imageView = UIImageView(frame: CGRect.zero)
    let filtersControl = UISegmentedControl(items: FilterNames)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //view.addSubview(mainGroup)
        //mainGroup.axis = UILayoutConstraintAxis.vertical
        //mainGroup.distribution = UIStackViewDistribution.fill
        
        //mainGroup.addArrangedSubview(imageView)
        //mainGroup.addArrangedSubview(filtersControl)
        
        filtersControl.frame.origin = CGPoint(x: 0, y: 55)
        filtersControl.isEnabled = true
        
        imageView.contentMode = .scaleAspectFit
        
        filtersControl.selectedSegmentIndex = 1
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            
            captureSession.addInput(input)
        } catch {
            print("can't access camera")
            return
        }
        
        // although we don't use this, it's required to get captureOutput invoked
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        let newView = VideoPreviewView(frame: view.frame)
        newView.session = captureSession
        
        view.addSubview(newView)
        view.addSubview(imageView)
        view.addSubview(filtersControl)
       
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        if captureSession.canAddOutput(videoOutput)
        {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        guard let filter = Filters[FilterNames[filtersControl.selectedSegmentIndex]] else
        {
            print("Couldn't add filter")
            return
        }
        print("IM HERE")
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        filter!.setValue(cameraImage, forKey: kCIInputImageKey)
        
        let filteredImage = UIImage(ciImage: filter!.value(forKey: kCIOutputImageKey) as! CIImage!)
        
        DispatchQueue.main.async {
            self.imageView.image = filteredImage
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        let topMargin = topLayoutGuide.length
        
        mainGroup.frame = CGRect(x: 0, y: topMargin, width: view.frame.width, height: view.frame.height - topMargin).insetBy(dx: 5, dy: 5)
    }
    
}


