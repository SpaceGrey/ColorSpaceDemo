//
//  CameraModel.swift
//  ColorSpaceDemo
//
//  Created by 王培屹 on 21/2/25.
//

import Foundation
import AVFoundation
import Photos
// a camera model for video recording.
class CameraModel: NSObject,AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        //save it to photo library
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL) // the preview and video file is still HDR but not apple log.
                } completionHandler: { (success, error) in
                    if success {
                        print("save success")
                    } else {
                        print("save failed")
                    }
                }
            }
        }
    }
    
    let session = AVCaptureSession()
    var backCamera: AVCaptureDevice!
    var output:AVCaptureMovieFileOutput!
    var previewSource:PreviewSource!
    let queue = DispatchQueue(label: "com.example.apple-samplecode.ColorSpaceDemo.video-recording", qos: .userInitiated)
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        // Access the capture session's connected preview layer.
        guard let previewLayer = session.connections.compactMap({ $0.videoPreviewLayer }).first else {
            fatalError("The app is misconfigured. The capture session should have a connection to a preview layer.")
        }
        return previewLayer
    }
    
    override init() {
        super.init()
        setup()
    }
    func setup(){
        session.sessionPreset = .inputPriority
        // get the back camera
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        backCamera = deviceDiscoverySession.devices.first!
        try! backCamera.lockForConfiguration()
        backCamera.automaticallyAdjustsVideoHDREnabled = false
        backCamera.isVideoHDREnabled = false
        let formats = backCamera.formats
        let appleLogFormat = formats.first { format in
            format.supportedColorSpaces.contains(.appleLog)
        }
        print(appleLogFormat!.supportedColorSpaces.contains(.appleLog))
        backCamera.activeFormat = appleLogFormat!
        backCamera.activeColorSpace = .appleLog
        print("colorspace is Apple Log \(backCamera.activeColorSpace == .appleLog)")
        
        backCamera.unlockForConfiguration()
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            session.addInput(input)
        } catch {
            print(error.localizedDescription)
        }
        // add output
        output = AVCaptureMovieFileOutput()
        session.addOutput(output)
        let connection = output.connection(with: .video)!
        print(
        output.outputSettings(for: connection)
        )
        /*
         ["AVVideoWidthKey": 1920, "AVVideoHeightKey": 1080, "AVVideoCodecKey": apch,<----- prores has enabled.
         "AVVideoCompressionPropertiesKey": {
             AverageBitRate = 220029696;
             ExpectedFrameRate = 30;
             PrepareEncodedSampleBuffersForPaddedWrites = 1;
             PrioritizeEncodingSpeedOverQuality = 0;
             RealTime = 1;
         }]
         */
        previewSource = DefaultPreviewSource(session: session)
        queue.async {
            self.session.startRunning()
        }
        
    }
    func startRecording(){
        let url = URL.movieFileURL
        output.startRecording(to: url, recordingDelegate: self)
    }
    func stopRecording(){
        output.stopRecording()
    }
}
extension URL {
    /// A unique output location to write a movie.
    static var movieFileURL: URL {
        URL.temporaryDirectory.appending(component: UUID().uuidString).appendingPathExtension(for: .quickTimeMovie)
    }
}
