//
//  CameraView.swift
//  spynDemoTest
//
//  Created by ParveenKhan on 14/11/24.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?  // Captured image passed back to SwiftUI
    @EnvironmentObject var viewModel: ImageViewModel  // ViewModel for saving the image

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func didCapturePhoto(_ image: UIImage) {
            parent.capturedImage = image

            // Save and upload the captured image
            if let imageData = image.pngData() {
                // Generate a unique image name
                let imageName = UUID().uuidString + ".png"

                // Save the image data to Realm
                parent.viewModel.saveImage(data: imageData, name: imageName)

                // Update upload status to "Uploading"
                parent.viewModel.updateUploadStatus(imageName: imageName, status: "Uploading")

                // Start the upload process
                parent.viewModel.uploadImage(imageData) { [weak self] result in
                    DispatchQueue.main.async {
                        
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(_):
                            // Update upload status to "Uploaded"
                            self.parent.viewModel.updateUploadStatus(imageName: imageName, status: "Uploaded")
                        case .failure(let error):
                            // Update upload status to "Failed"
                            self.parent.viewModel.updateUploadStatus(imageName: imageName, status: "Failed")
                            print("Upload failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCapturePhoto(_ image: UIImage)
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: CameraViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput = try! AVCaptureDeviceInput(device: videoCaptureDevice)
        captureSession.addInput(videoInput)

        photoOutput = AVCapturePhotoOutput()
        captureSession.addOutput(photoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        // Add Capture Button
        addCaptureButton()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        delegate?.didCapturePhoto(image)
    }

    private func addCaptureButton() {
        let captureButton = UIButton(type: .custom)
        captureButton.frame = CGRect(x: (view.frame.width - 70) / 2, y: view.frame.height - 150, width: 70, height: 70)
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 35
        captureButton.layer.borderWidth = 4
        captureButton.layer.borderColor = UIColor.gray.cgColor
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)
    }

    @objc private func captureButtonTapped() {
        capturePhoto()
    }
}

#Preview {
   // CameraView(capturedImage: UIImage())
}
