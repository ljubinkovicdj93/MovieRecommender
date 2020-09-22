//
//  UIImageView+Extensions.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import UIKit

extension UIImageView {
    func loadImage(at url: URL) {
        UIImageLoader.loader.downloadImage(url, for: self)
    }

    func cancelImageLoad() {
        UIImageLoader.loader.cancel(for: self)
    }
}
