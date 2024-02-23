
import Foundation
import UIKit

struct PhotoUnsplash: Decodable {
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Decodable {
    let urls: UnsplashPhotoURLs
}

struct UnsplashPhotoURLs: Decodable {
    let regular: String
}

enum NetworkErrors: Error {
    case badURL, badRequest, badREsponse, noData, pageDoNotExist
}
