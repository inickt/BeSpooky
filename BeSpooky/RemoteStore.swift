//
//  RemoteStore.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/29/22.
//

import AVKit
import MultipeerKit
import SwiftUI

class RemoteStore: ObservableObject {
    @Published private(set) var frontImage: UIImage?
    @Published private(set) var rearImage: UIImage?

    @Published var frontPhoto: UIImage?
    @Published var rearPhoto: UIImage?
    @Published var takingPictue: Bool = false

    private(set) lazy var transceiver: MultipeerTransceiver = {
        let transceiver: MultipeerTransceiver = .bespooky
        transceiver.receive(Payload.self) { [weak self] payload, peer in
            let image = UIImage(data: payload.frame)
            switch payload.source {
            case .front:
                self?.frontImage = image
            case .rear:
                self?.rearImage = image
            }
        }
        transceiver.receive(PhotoCapture.self) { [weak self] payload, _ in
            let image = UIImage(data: payload.photo)
            switch payload.source {
            case .front:
                self?.frontPhoto = image
            case .rear:
                self?.rearPhoto = image
            }
            if self?.frontPhoto != nil && self?.rearPhoto != nil {
                self?.takingPictue = false
            }
        }
        return transceiver
    }()

    init() {
        transceiver.resume()
    }

    func clearPhotos() {
        self.frontPhoto = nil
        self.rearPhoto = nil
        self.takingPictue = false
    }

    func takePicture() {
        takingPictue = true
        transceiver.broadcast(TakePicture())
    }

    var readyForUpload: Bool {
        rearPhoto != nil && frontPhoto != nil
    }

    func upload() {
        guard let main = frontPhoto,
              let preview = rearPhoto else {
            return
        }

        func convertFormField(named name: String, value: String, using boundary: String) -> String {
            var fieldString = "--\(boundary)\r\n"
            fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
            fieldString += "\r\n"
            fieldString += "\(value)\r\n"

            return fieldString
        }

        func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
            let data = NSMutableData()

            data.appendString("--\(boundary)\r\n")
            data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
            data.appendString("Content-Type: \(mimeType)\r\n\r\n")
            data.append(fileData)
            data.appendString("\r\n")

            return data as Data
        }


        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: URL(string: "https://bespooky.nickt.dev/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = NSMutableData()


        httpBody.append(
            convertFileData(
                fieldName: "main",
                fileName: "main.jpg",
                mimeType: "image/jpeg",
                fileData: main.jpegData(compressionQuality: 0.9)!,
                using: boundary
            )
        )
        httpBody.append(
            convertFileData(
                fieldName: "preview",
                fileName: "preview.jpg",
                mimeType: "image/jpeg",
                fileData: preview.jpegData(compressionQuality: 0.9)!,
                using: boundary
            )
        )

        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data

        URLSession.shared.dataTask(with: request, completionHandler: { [weak self] _, _, _ in
            DispatchQueue.main.async {
                self?.clearPhotos()
            }
        }).resume()
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
