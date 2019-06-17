//
//  CameraViewController.swift
//  Surround
//
//  Created by Frank Chen on 2019-04-17.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        setupCaptureSession()
    }
    
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }
    
    @IBAction func tapDismissButton(_ sender: UIButton) {
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func tapCaptureButton(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {return}
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String:previewFormatType]
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!)
        let previewImage = UIImage(data: imageData!)
        
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    let output = AVCapturePhotoOutput()
    fileprivate func setupCaptureSession(){
        let captureSession = AVCaptureSession()
        
        //1.set up inputs
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {return}
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
            }
        } catch let err{
            print("Could not setup camera input:", err)
        }
        //2.set up outputs
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
        }
        
        //3.setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        captureSession.startRunning()
        
    }
    
    


}
