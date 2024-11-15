//
//  ImageModel.swift
//  spynDemoTest
//
//  Created by ParveenKhan on 13/11/24.
//

import Foundation
import RealmSwift

class ImageModel: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var imageData: Data? = nil
    @objc dynamic var imageName: String = ""
    @objc dynamic var captureDate: Date = Date()
    @objc dynamic var uploadStatus: String = "Pending" // Pending, Uploading, Completed
    @objc dynamic var uploadProgress: Float = 0.0

    override static func primaryKey() -> String? {
        return "id"
    }
}
