//
//  VideoRecorderViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/29/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit

import AVFoundation
import Firebase

class VideoRecorderController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    var button1: UIBarButtonItem!
    
    @IBOutlet weak var camPreview: UIView!
    
    @IBOutlet weak var recordingLabel: UILabel!
    
    @IBOutlet weak var recordingCircle: UIView!
    let cameraButton = UIView()
    
    @IBOutlet weak var recordingTimerLabel: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    var timerSeconds = 15
    
    var timer = Timer()
    
    var isTimerRunning = false
    
    @IBOutlet weak var recordingLabelView: UIView!
    let captureSession = AVCaptureSession()
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var activeInput: AVCaptureDeviceInput!
    
    var outputURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if setupSession() {
            setupPreview()
            startSession()
        }
        recordingLabelView.isHidden = true
        cameraButton.isUserInteractionEnabled = true

        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(swapCamera)) // action:#selector(Class.MethodName) for swift 3
        button1.title = "Switch Camera"
        self.navigationItem.rightBarButtonItem  = button1

        
        recordingCircle.layer.cornerRadius = 7
        recordingCircle.layer.masksToBounds = true
        
        recordButton.layer.cornerRadius = 30
        recordingCircle.layer.masksToBounds = true
        recordButton.setTitle("REC", for: .normal)
        recordButton.setImage(nil, for: .normal)

        
        
        
    }
    
    /// Swap camera and reconfigures camera session with new input
    @objc fileprivate func swapCamera() {
        
        
        // Get current input
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        
        // Begin new session configuration and defer commit
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        // Create new capture device
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }
        
        // Create new capture input
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        // Swap capture device inputs
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] { for input in inputs { captureSession.removeInput(input) }
        }
        captureSession.addInput(deviceInput)
        
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            
        }
    }
    
    /// Create new capture device with requested position
    fileprivate func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices
        
        //if let devices = devices {
        for device in devices {
            if device.position == position {
                return device
            }
        }
        //}
        
        return nil
    }
    
    @IBAction func videoRecordButton(_ sender: UIButton) {
      
        sender.pulsate()
        
        if recordingLabelView.isHidden == true {
            recordingLabelView.isHidden = false
            recordingCircle.blink()
            runTimer()
            recordButton.setTitle("", for: .normal)
            recordButton.setImage(UIImage(imageLiteralResourceName: "stopIcon"), for: .normal)
            button1.title = ""
            
        } else {
            recordingLabelView.isHidden = true
            timer.invalidate()
            timerSeconds = 15
            recordingTimerLabel.text = "\(timerSeconds)s"
            recordButton.setTitle("REC", for: .normal)
            recordButton.setImage(nil, for: .normal)
        }
        
        startRecording()
 
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }
    
    func runTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTimer() {
        
        if timerSeconds == 0 {
            
           recordButton.sendActions(for: .touchUpInside)
            
            
        } else {
        
            timerSeconds -= 1     //This will decrement(count down)the seconds.
            
            recordingTimerLabel.text = "\(timerSeconds)s"
            
        }
            
        
    }
    
    
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
        
        
        // Setup Camera
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            
            let input = try AVCaptureDeviceInput(device: camera)
            
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            
            if captureSession.canAddInput(input) {
                
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            
            movieOutput.movieFragmentInterval = CMTime.invalid
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        
        if !captureSession.isRunning {
            
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    @objc func startCapture() {
        
        startRecording()
        
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! VideoPlayback
        
        vc.videoURL = sender as? URL
        
    }
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            
            if (device.isSmoothAutoFocusSupported) {
                
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
        
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if (error != nil) {
            
            print("Error recording movie: \(error!.localizedDescription)")
            
        } else {
            
            let videoRecorded = outputURL! as URL

            
            let filePath = videoRecorded.absoluteString
            var fileSize : UInt64
            
            do {
     
                let attr = try FileManager.default.attributesOfItem(atPath: filePath)
                fileSize = attr[FileAttributeKey.size] as! UInt64
                

            } catch {
                print("Error: \(error)")
            }
            
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
            
        }
        
}
    
    override func viewWillAppear(_ animated: Bool) {
        button1.title = "Switch Camera"
    }
}

extension UIView {
    func blink() {
        UIView.animate(withDuration: 0.5, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 })
    }
}

