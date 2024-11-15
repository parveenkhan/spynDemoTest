//
//  ImageViewModel.swift
//  spynDemoTest
//
//  Created by ParveenKhan on 13/11/24.
//

import Foundation
import RealmSwift
import Combine

class ImageViewModel: ObservableObject {
    @Published var images: [ImageModel] = []
    private var realm = try! Realm()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        fetchImages()
    }
    
    func fetchImages() {
        let results = realm.objects(ImageModel.self).sorted(byKeyPath: "captureDate", ascending: false)
        self.images = Array(results)
    }
    
    func saveImage(data: Data, name: String) {
        let newImage = ImageModel()
        newImage.imageData = data
        newImage.imageName = name
        try! realm.write {
            realm.add(newImage)
        }
        fetchImages()
    }
    
    func updateUploadProgress(image: ImageModel, progress: Float, status: String) {
        try! realm.write {
            image.uploadProgress = progress
            image.uploadStatus = status
        }
        fetchImages()
    }
    
    func uploadImage(_ image: ImageModel) {
        guard let imageData = image.imageData else { return }
        updateUploadProgress(image: image, progress: 0.0, status: "Uploading")
        
        let url = URL(string: "https://example.com/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=Boundary", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(data: imageData, name: image.imageName)
        let uploadTask = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                self.updateUploadProgress(image: image, progress: 0.0, status: "Failed")
                return
            }
            self.updateUploadProgress(image: image, progress: 1.0, status: "Completed")
        }
        uploadTask.resume()
    }
    
    private func createMultipartBody(data: Data, name: String) -> Data {
        var body = Data()
        let boundary = "Boundary"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(name)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

extension ImageViewModel {
    func uploadImage(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://www.clippr.ai/api/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Create the multipart body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Assign body to the request
        request.httpBody = body

        // Perform the upload task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                completion(.failure(error))
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(.success(responseString))
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse server response"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func updateUploadStatus(imageName: String, status: String) {
        if let image = images.first(where: { $0.imageName == imageName }) {
            try! realm.write {
                image.uploadStatus = status
            }
            fetchImages()
        }
    }
}
