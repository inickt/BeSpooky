//
//  FrontPreviewView.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/22/22.
//

import SwiftUI

struct FrontPreviewView: View {
    @StateObject private var store = CameraCaptureStore(source: .front)

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            previewView
                .rotationEffect(.degrees(180))
                .cornerRadius(38.5) // Match iPhone X screen corner radius
                .ignoresSafeArea(edges: [.leading, .bottom, .trailing])
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            UIApplication.shared.isStatusBarHiddenHack = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            UIApplication.shared.isStatusBarHiddenHack = false
        }
    }

    @ViewBuilder private var previewView: some View {
        if let image = store.rearImage {
            Image(uiImage: image)
        } else {
            Color.gray
        }
    }
}
