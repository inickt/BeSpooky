//
//  CameraCaptureStore.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/20/22.
//

import AVKit
import MultipeerKit
import SwiftUI

class CameraCaptureStore: NSObject, ObservableObject {
    private let transceiver: MultipeerTransceiver
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "dev.nickt.BeSpooky.CameraCaptureStore")
    private var throttle = true

    init(transceiver: MultipeerTransceiver) {
        self.transceiver = transceiver
        super.init()
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .medium
        guard let videoDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            captureSession.addInput(videoDeviceInput)
            captureSession.addOutput(videoDataOutput)
            let videoConnection = videoDataOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait

            print(videoDevice.activeFormat.videoSupportedFrameRateRanges)

            captureSession.commitConfiguration()
            captureSession.startRunning()
        } catch let error as NSError {
            print("error \(error)")
        }
    }
}

extension CameraCaptureStore: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        throttle.toggle()
        guard throttle else { return }

        guard let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: cvImageBuffer)
        let uiImage = UIImage(ciImage: ciImage)
        guard let frame = uiImage.jpegData(compressionQuality: 0.2) else {
            print("Unable to compress frame")
            return
        }

        if !transceiver.availablePeers.isEmpty {
            transceiver.broadcast(Payload(frame: frame))
        }
    }
}
