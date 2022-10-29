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
        }
        return transceiver
    }()

    init() {
        transceiver.resume()
    }
}
