//
//  Loadable.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import UIKit

protocol HasLoadingView: class {
    func startLoading()
    func stopLoading()
}

protocol LoadingLogic: HasLoadingView {
    var loadable: HasLoadingView? { get }
}

extension LoadingLogic {
    func startLoading() {
        loadable?.startLoading()
    }

    func stopLoading() {
        loadable?.stopLoading()
    }
}

extension UIView: HasLoadingView {
    private struct Constants {
        static let TagNumber = 42
    }

    func startLoading() {
        DispatchQueue.main.async { [weak self] in guard let self = self else { return }
            let spinner = UIActivityIndicatorView(frame: self.bounds)
            spinner.tag = Constants.TagNumber
            spinner.style = .large
            spinner.backgroundColor = .lightGray
            spinner.color = .black
            spinner.center = self.center
            spinner.hidesWhenStopped = true

            spinner.startAnimating()

            self.addSubview(spinner)
            spinner.pinToEdges()
        }
    }

    func stopLoading() {
        DispatchQueue.main.async {
            for subview in self.subviews {
                if let spinner = subview as? UIActivityIndicatorView,
                   spinner.tag == Constants.TagNumber {

                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                    break
                }
            }
        }
    }
}

extension HasLoadingView where Self: UIViewController {
    func startLoading() {
        DispatchQueue.main.async {
            self.view.startLoading()
        }
    }

    func stopLoading() {
        DispatchQueue.main.async {
            self.view.stopLoading()
        }
    }
}

