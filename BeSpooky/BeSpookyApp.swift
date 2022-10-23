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
    @StateObject private var store: Store = .init()

    var body: some Scene {
        WindowGroup {
            RoleSelectionView()
                .onAppear {
                    UIViewController.swizzleHomeIndicatorProperty()
                }
        }
    }
}
