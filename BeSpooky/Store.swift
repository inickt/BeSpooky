//
//  Store.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/18/22.
//

import AVKit
import MultipeerKit
import SwiftUI

class Store: ObservableObject {
    @Published private(set) var image: UIImage?

    private(set) lazy var transceiver: MultipeerTransceiver = {
        var config = MultipeerConfiguration.default
        config.serviceType = "BeSpooky"
        config.security.encryptionPreference = .none

        let t = MultipeerTransceiver(configuration: config)

        t.receive(Payload.self) { [weak self] payload, peer in
            print("Got payload: \(payload)")
            self?.image = UIImage(data: payload.frame)
        }

        return t
    }()

    init() {
        transceiver.resume()
    }
}
