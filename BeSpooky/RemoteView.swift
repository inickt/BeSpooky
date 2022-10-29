//
//  RemoteView.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/22/22.
//

import SwiftUI

struct RemoteView: View {
    @StateObject var store = RemoteStore()

    @State private var flipped = false
    @State private var leading = true

    @State private var previewOffset = CGSize.zero

    var body: some View {
        VStack {
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
            Button("Take Photo") {
                store.transceiver.broadcast(TakePicture())
            }
            Button("Discard") {
                store.rearPhoto = nil
                store.frontPhoto = nil
            }

            if store.rearPhoto != nil && store.frontPhoto != nil {
                Button("Upload Pictuere") {
                    guard let main = store.frontPhoto,
                          let preview = store.rearPhoto else {
                        return
                    }

                    func convertFormField(named name: String, value: String, using boundary: String) -> String {
                        var fieldString = "--\(boundary)\r\n"
                        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
                        fieldString += "\r\n"
                        fieldString += "\(value)\r\n"

                        return fieldString
                    }

                    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
                        let data = NSMutableData()

                        data.appendString("--\(boundary)\r\n")
                        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
                        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
                        data.append(fileData)
                        data.appendString("\r\n")

                        return data as Data
                    }


                    let boundary = "Boundary-\(UUID().uuidString)"

                    var request = URLRequest(url: URL(string: "https://bespooky.nickt.dev/upload")!)
                    request.httpMethod = "POST"
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                    let httpBody = NSMutableData()


                    httpBody.append(
                        convertFileData(
                            fieldName: "main",
                            fileName: "main.jpg",
                            mimeType: "image/jpeg",
                            fileData: main.jpegData(compressionQuality: 0.9)!,
                            using: boundary
                        )
                    )
                    httpBody.append(
                        convertFileData(
                            fieldName: "preview",
                            fileName: "preview.jpg",
                            mimeType: "image/jpeg",
                            fileData: preview.jpegData(compressionQuality: 0.9)!,
                            using: boundary
                        )
                    )

                    httpBody.appendString("--\(boundary)--")

                    request.httpBody = httpBody as Data

                    URLSession.shared.dataTask(with: request, completionHandler: { _, _, _ in
                        print("completed upload")
                    }).resume()

                }
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
        if let image = store.rearPhoto ?? store.rearImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Color.red
        }
    }

    @ViewBuilder private var secondaryView: some View {
        if let image = store.frontPhoto ?? store.frontImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Color.orange
        }
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
