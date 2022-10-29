//
//  Payload.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/18/22.
//

import Foundation

struct Payload: Codable {
    let source: Source
    let frame: Data
}

enum Source: Codable, Equatable {
    case front
    case rear
}
