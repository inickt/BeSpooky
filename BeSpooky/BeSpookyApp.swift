//
//  BeSpookyApp.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/18/22.
//

import MultipeerKit
import SwiftUI

@main
struct BeSpookyApp: App {
    @StateObject private var store: TransceiverStore = .init()

    var body: some Scene {
        WindowGroup {
            RoleSelectionView()
                .environmentObject(store)
                .onAppear {
                    UIViewController.swizzleHomeIndicatorProperty()
                }
        }
    }
}
