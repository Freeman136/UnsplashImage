//
//  NetworkManager.swift
//  UnsplashImage
//
//  Created by Andrew on 19.02.2024.

import Foundation

final class NetworkManager {
    static var paginationCounter = 1
    static let shared = NetworkManager()
    private init() {}
    func loadDataUrls(searchRequest: String, completion: @escaping (Result<PhotoUnsplash, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/search/photos?client_id=Ip0XA55zY7b7-d19osq1L5btGg-YCeDZVpnnJjXqHxs&query=\(searchRequest)&page=\(NetworkManager.paginationCounter)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkErrors.badURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(NetworkErrors.badRequest))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkErrors.noData))
                return
            }

            do {
                let response = try JSONDecoder().decode(PhotoUnsplash.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
