//
//  MovieListWorker.swift
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

class MovieListWorker {
    enum MovieListWorkerError: Error {
        case noMovieDatabaseConfigFound
    }

    let networkService: NetworkService
    let userDefaultsStorable: UserDefaultsStorable

    init(networkService: NetworkService = URLNetworkService(configuration: MovieDatabaseConfiguration.shared.apiConfiguration), userDefaultsStorable: UserDefaultsStorable = UserDefaults.standard) {
        self.userDefaultsStorable = userDefaultsStorable
        self.networkService = networkService
    }

    func fetchPopularMovies(_ completion: @escaping (Swift.Result<GetPopularMoviesResponseModel, Error>) -> Void) {
        fetchMovieDatabaseConfiguration { [weak self] result in guard let self = self else { return }
            guard let _ = try? result.get() else { completion(.failure(MovieListWorkerError.noMovieDatabaseConfigFound)); return }
            GetPopularMoviesOperation().execute(in: self.networkService, completion: completion)
        }
    }

    private func fetchMovieDatabaseConfiguration(_ completion: @escaping (Swift.Result<GetMovieDatabaseConfigurationResponseModel, Error>) -> Void) {
        if let cachedConfiguration: GetMovieDatabaseConfigurationResponseModel = try? userDefaultsStorable.getObject(forKey: MovieDatabaseConfiguration.Constants.movieDbConfigurationKey) {
            completion(.success(cachedConfiguration))
        } else {
            GetMovieDatabaseConfigurationOperation().execute(in: networkService, completion: { [weak self] result in guard let self = self else { return }
                switch result {
                    case let .success(config):
                        MovieDatabaseConfiguration.shared.movieConfiguration = config
                        try? self.userDefaultsStorable.saveObject(config, forKey: MovieDatabaseConfiguration.Constants.movieDbConfigurationKey)
                        completion(.success(config))
                    case let .failure(error):
                        completion(.failure(error))
                }
            })
        }
    }
}
