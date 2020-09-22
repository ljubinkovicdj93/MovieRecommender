//
//  ImageUtils.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import UIKit

protocol ImageDownloadableAdapter {
    @discardableResult
    func downloadImage(_ url: URL, completion: @escaping (Swift.Result<UIImage, Error>) -> Void) -> UUID?
    func cancel(_ uuid: UUID)
}

class ImageDownloader: ImageDownloadableAdapter {

    private var runningRequests = [UUID: URLSessionDataTask]()

    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.name = "image_cache"
        cache.totalCostLimit = 100_000
        cache.countLimit = 50

        return cache
    }()

    private let session: URLSession

    init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }

    func downloadImage(_ url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        let imageUrlString = url.absoluteString as NSString
        if let image = imageCache.object(forKey: imageUrlString) {
            print("🟢🟢🟢🟢 FETCHING FROM CACHE: \(imageUrlString) 🟢🟢🟢🟢")
            completion(.success(image))
            return nil
        }

        let uuid = UUID()

        let dataTask = self.session.dataTask(with: url) { data, response, error in
            defer { self.runningRequests.removeValue(forKey: uuid) }

            if let data = data, let image = UIImage(data: data) {
                self.imageCache.setObject(image, forKey: imageUrlString)
                completion(.success(image))
                return
            }

            if let error = error {
                completion(.failure(error))
                return
            }
        }

        dataTask.resume()

        runningRequests[uuid] = dataTask

        return uuid
    }

    func cancel(_ uuid: UUID) {
        print("❌❌❌❌ CANCELLING IMAGE REQUEST ❌❌❌❌")
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}

class UIImageLoader {
    static let loader = UIImageLoader()

    private var imageDownloader: ImageDownloadableAdapter = ImageDownloader()
    private var uuidMap = [UIImageView: UUID]()

    private init() {}

    func downloadImage(_ url: URL, for imageView: UIImageView) {

        imageView.startLoading()
        let token = imageDownloader.downloadImage(url) { result in
            defer {
                imageView.stopLoading()
                self.uuidMap.removeValue(forKey: imageView)
            }
            do {
                let image = try result.get()
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } catch {
                DispatchQueue.main.async {
                    imageView.image = #imageLiteral(resourceName: "placeholder")
                }
            }
        }

        uuidMap[imageView] = token
    }

    func cancel(for imageView: UIImageView) {
        if let uuid = uuidMap[imageView] {
            imageDownloader.cancel(uuid)
            uuidMap.removeValue(forKey: imageView)
        }
    }
}

