//
//  RemoteView.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/22/22.
//

import SwiftUI

struct RemoteView: View {
    @EnvironmentObject var store: TransceiverStore

    @State private var flipped = false
    @State private var leading = true

    @State private var previewOffset = CGSize.zero

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            GeometryReader { geometry in
                ZStack(alignment: leading ? .topLeading : .topTrailing) {
                    mainView
                    previewView
                        .aspectRatio(3/4, contentMode: .fit)
                        .frame(width: geometry.size.width * 0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 1)
                        )
                        .offset(previewOffset)
                        .padding(12)
                        .onTapGesture {
                            withAnimation {
                                flipped.toggle()
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { v in
                                    withAnimation {
                                        previewOffset = .init(width: v.location.x, height: v.location.y)
                                    }
                                }
                                .onEnded { v in
                                    withAnimation {
                                        previewOffset = .zero
                                        leading = v.location.x < geometry.size.width / 2
                                    }
                                }
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .aspectRatio(3/4, contentMode: .fit)
            }
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder private var mainView: some View {
        if flipped {
            secondaryView
        } else {
            primaryView
        }
    }

    @ViewBuilder private var previewView: some View {
        if flipped {
            primaryView
        } else {
            secondaryView
        }
    }

    @ViewBuilder private var primaryView: some View {
        if let image = store.rearImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Color.red
        }
    }

    @ViewBuilder private var secondaryView: some View {
        if let image = store.frontImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Color.orange
        }
    }
}
