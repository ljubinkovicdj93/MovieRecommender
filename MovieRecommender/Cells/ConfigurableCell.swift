//
//  ConfigurableCell.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

public protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

public extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public protocol ConfigurableCell: ReusableCell {
    associatedtype Model

    func configure(_ item: Model)
}
