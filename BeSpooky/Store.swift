//
//  Store.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/18/22.
//

import MultipeerKit
import SwiftUI

class Store: ObservableObject {
    @Published private(set) var text: String = ""

    private(set) lazy var transceiver: MultipeerTransceiver = {
        var config = MultipeerConfiguration.default
        config.serviceType = "BeSpooky"
        config.security.encryptionPreference = .required

        let t = MultipeerTransceiver(configuration: config)

        t.receive(Payload.self) { [weak self] payload, peer in
            print("Got payload: \(payload)")
            self?.text = "\(payload.value) \(peer.name)"
        }

        return t
    }()

    init() {
        transceiver.resume()
    }
}
