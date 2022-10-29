//
//  TransceiverStore.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/18/22.
//

import AVKit
import MultipeerKit
import SwiftUI

class TransceiverStore: ObservableObject {
    @Published private(set) var frontImage: UIImage?
    @Published private(set) var rearImage: UIImage?

    private(set) lazy var transceiver: MultipeerTransceiver = {
        var config = MultipeerConfiguration.default
        config.serviceType = "BeSpooky"
        config.security.encryptionPreference = .none

        let transceiver = MultipeerTransceiver(configuration: config)

        transceiver.receive(Payload.self) { [weak self] payload, peer in
            let image = UIImage(data: payload.frame)
            switch payload.source {
            case .front:
                self?.frontImage = image
            case .rear:
                self?.rearImage = image
            }
        }

        return transceiver
    }()

    init() {
        transceiver.resume()
    }
}
