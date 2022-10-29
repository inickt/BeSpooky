//
//  Role.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/28/22.
//

import Foundation

enum Role: String, CaseIterable, Identifiable {
    case remote
    case frontPreview
    case rearCamera

    var id: String { rawValue }
}
