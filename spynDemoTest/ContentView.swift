//
//  ContentView.swift
//  spynDemoTest
//
//  Created by ParveenKhan on 12/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ImageViewModel
    @State private var showCamera = false
    @State private var capturedImage: UIImage?

    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.images) { image in
                    HStack {
                        // Display Image Thumbnail
                        if let imageData = image.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                        }

                        // Image Details and Progress
                        VStack(alignment: .leading) {
                            Text(image.imageName)
                                .font(.headline)
                                .lineLimit(1)
                            ProgressView(value: image.uploadProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: 150, height: 10)
                            Text(image.uploadStatus)
                                .foregroundColor(statusColor(for: image.uploadStatus))
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Captured Images")
                .toolbar {
                    Button(action: { showCamera.toggle() }) {
                        Label("Camera", systemImage: "camera")
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(capturedImage: $capturedImage)
                    .environmentObject(viewModel)
            }
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "Uploading": return .blue
        case "Uploaded": return .green
        case "Failed": return .red
        default: return .gray
        }
    }
}


#Preview {
    ContentView()
}
