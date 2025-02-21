# Apple Log Color Space Doesn't Work

I set the device format and colorspace to Apple Log and turn off the HDR, why the movie output is still in HDR format rather than Prores Log?

```swift
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
```

Is there anything I missed?