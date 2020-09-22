//
//  UIView+Extensions.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import UIKit

extension UIView {
    func pinToEdges() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
    }
}
