//
//  ViewStyle.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import UIKit

typealias ViewStyleHandler<T: UIView> = (T) -> Void

struct ViewStyle<T: UIView> {
    let styling: ViewStyleHandler<T>
}

extension ViewStyle {
    static func compose(_ styles: ViewStyle<T>...) -> ViewStyle<T> {
        return ViewStyle { view in
            for style in styles {
                style.styling(view)
            }
        }
    }

    func apply(to view: T) {
        styling(view)
    }
}
