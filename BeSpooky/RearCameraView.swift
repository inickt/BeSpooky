//
//  RearCameraView.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/22/22.
//

import SwiftUI

struct RearCameraView: View {
    @EnvironmentObject private var store: TransceiverStore
    @State private var captureStore: CameraCaptureStore?

    @State private var originalBrightness: CGFloat = UIScreen.main.brightness

    var body: some View {
        Text("hello")
            .onAppear {
                captureStore = .init(transceiver: store.transceiver, source: .rear)
                UIApplication.shared.isIdleTimerDisabled = true
                UIScreen.main.brightness = .zero
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
                UIScreen.main.brightness = originalBrightness
            }
    }
}
