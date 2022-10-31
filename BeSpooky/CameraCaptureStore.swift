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
    private let source: Source

    @Published private(set) var rearImage: UIImage?
    @Published private(set) var showPictureSpinner = false

    let sessionPreset: AVCaptureSession.Preset

    private(set) lazy var transceiver: MultipeerTransceiver = {
        let transceiver: MultipeerTransceiver = .bespooky
        if source == .front {
            transceiver.receive(Payload.self) { [weak self] payload, peer in
                let image = UIImage(data: payload.frame)
                switch payload.source {
                case .rear:
                    self?.rearImage = image
                default:
                    break
                }
            }
        }
        transceiver.receive(TakePicture.self) { [weak self] _, _ in
            guard let self = self else { return }
            self.showPictureSpinner = true
            self.takingPicture = true
            self.captureSession.sessionPreset = .photo
            DispatchQueue.main.asyncAfter(deadline: self.source == .rear ? .now() + 2.5 : .now() + 0.1) {
                guard let uncompressedPixelType = self.photoDataOutput.supportedPhotoPixelFormatTypes(for: .tif).first else {
                    print("No pixel format types available")
                    return
                }
                let settings = AVCapturePhotoSettings(format: [
                    kCVPixelBufferPixelFormatTypeKey as String : uncompressedPixelType
                ])
                settings.flashMode = .off

                self.photoDataOutput.capturePhoto(with: settings, delegate: self)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                self.showPictureSpinner = false
            }
        }
        return transceiver
    }()

    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "dev.nickt.BeSpooky.CameraCaptureStore")
    private let photoDataOutput = AVCapturePhotoOutput()
    private var throttle = 10
    private var takingPicture = false

    init(source: Source) {
        self.source = source
        self.sessionPreset = source == .rear ? .medium : .low
        super.init()
        transceiver.resume()

        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        photoDataOutput.isHighResolutionCaptureEnabled = false

        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: source == .front ? .front : .back) else { return }
        do {
            if videoDevice.isLowLightBoostSupported {
                videoDevice.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            captureSession.addInput(videoDeviceInput)
            captureSession.addOutput(videoDataOutput)
            captureSession.addOutput(photoDataOutput)

            let videoConnection = videoDataOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portraitUpsideDown
            videoConnection?.isVideoMirrored = source == .front

            captureSession.commitConfiguration()
            captureSession.startRunning()

            videoConnection?.videoScaleAndCropFactor = 1.0
        } catch let error as NSError {
            print("error \(error)")
        }
    }
}

extension CameraCaptureStore: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        throttle += 1
        guard throttle >= 2 , !takingPicture else { return }
        throttle = 0

        guard let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: cvImageBuffer)
        let uiImage = UIImage(ciImage: ciImage)
        guard let frame = uiImage.jpegData(compressionQuality: 0) else {
            print("Unable to compress frame")
            return
        }

        if !transceiver.availablePeers.isEmpty {
            transceiver.broadcast(Payload(source: source, frame: frame))
        }
    }
}

extension CameraCaptureStore: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let cgImage = photo.cgImageRepresentation() else {
            return
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: source == .front ? .rightMirrored : .left)
        guard let photo = image.resized(withPercentage: 0.5)?.jpegData(compressionQuality: 0.5) else {
            print("Unable to compress frame")
            return
        }
        if !transceiver.availablePeers.isEmpty {
            transceiver.broadcast(PhotoCapture(source: source, photo: photo))
        }
        self.takingPicture = false
        self.captureSession.sessionPreset = sessionPreset
    }
}


extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
