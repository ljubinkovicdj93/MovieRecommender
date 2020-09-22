//
//  MovieDetailsConfigurator.swift
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

extension MovieDetailsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.passDataToNextScene(segue: segue)
    }
}

// MARK: - Connects View, Interactor, and Presenter
class MovieDetailsConfigurator {
    
    static let sharedInstance = MovieDetailsConfigurator()
    
    private init() {}
    
    // MARK: - Configuration
    
    func configure(_ viewController: MovieDetailsViewController) {
        let presenter = MovieDetailsPresenter()
        presenter.viewController = viewController
        
        let interactor = MovieDetailsInteractor()
        interactor.presenter = presenter
        
        let router = MovieDetailsRouter()
        router.viewController = viewController
        router.dataStore = interactor
        
        viewController.interactor = interactor
        viewController.router = router
    }
}
