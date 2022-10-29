//
//  MultipeerTransceiver+Extensions.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/29/22.
//

import MultipeerKit

extension MultipeerTransceiver {
    static var bespooky: MultipeerTransceiver {
        var config = MultipeerConfiguration.default
        config.serviceType = "BeSpooky"
        config.security.encryptionPreference = .none
        return MultipeerTransceiver(configuration: config)
    }
}
