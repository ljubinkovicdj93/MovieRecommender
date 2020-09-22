//
//  MovieDetailsPresenter.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//  Copyright (c) 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol MovieDetailsPresentationLogic {
    func presentSomething(_ response: MovieDetails.Something.Response)
}

class MovieDetailsPresenter: MovieDetailsPresentationLogic {
    
    weak var viewController: MovieDetailsDisplayLogic?
    
    // MARK: Do something
    
    func presentSomething(_ response: MovieDetails.Something.Response) {
        let viewModel = MovieDetails.Something.ViewModel()
        viewController?.displaySomething(viewModel)
    }
}