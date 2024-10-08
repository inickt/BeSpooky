//
//  RearCameraView.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/22/22.
//

import SwiftUI

struct RearCameraView: View {
    @StateObject private var store = CameraCaptureStore(source: .rear)
    @State private var originalBrightness: CGFloat = UIScreen.main.brightness

    var body: some View {
        Text("")
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                UIScreen.main.brightness = .zero
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
                UIScreen.main.brightness = originalBrightness
            }
    }
}
