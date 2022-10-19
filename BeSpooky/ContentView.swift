//
//  ContentView.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/18/22.
//

import MultipeerKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        VStack {
            Text(store.text)
            Button(action: {
                store.transceiver.broadcast(Payload(value: "Foobar"))
            }) {
                Text("SEND")
            }
        }
        .padding()
    }
}
