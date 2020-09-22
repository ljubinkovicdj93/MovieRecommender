//
//  MovieCell.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import UIKit

class MovieCell: UITableViewCell, ConfigurableCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!

    func configure(_ item: Movie) {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.black.cgColor

        title.text = item.title

        if let imageUrl = item.imageUrl {
            thumbnail.loadImage(at: imageUrl)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnail.cancelImageLoad()
        thumbnail.image = nil
    }
}
