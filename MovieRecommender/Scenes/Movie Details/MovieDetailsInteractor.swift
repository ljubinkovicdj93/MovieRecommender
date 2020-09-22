//
//  MovieDetailsInteractor.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//  Copyright (c) 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import SafariServices
import UIKit

protocol MovieDetailsBusinessLogic {
    func requestInitialState()
    func playMovieTrailer()
}

protocol MovieDetailsDataStore {
    var movie: Movie? { get set }
}

class MovieDetailsInteractor: MovieDetailsBusinessLogic, MovieDetailsDataStore {
    var movie: Movie?

    var presenter: MovieDetailsPresentationLogic?
    lazy var worker = MovieDetailsWorker()

    // MARK: Business Logic
    func requestInitialState() {
        guard self.movie != nil else { return }

        presenter?.startLoading()
        worker.getMovieInformation(for: self.movie!) { [weak self] result in guard let self = self else { return }
            defer {
                DispatchQueue.main.async {
                    self.presenter?.stopLoading()
                }
            }

            switch result {
                case let .success(videoResponse):
                    DispatchQueue.main.async {
                        self.movie?.videos = videoResponse.videos
                        self.presenter?.presentInitialState(MovieDetails.InitialState.Response(movie: self.movie!))
                    }
                case let .failure(error):
                    #warning("TODO: Handle error")
                    print(error.localizedDescription)
            }
        }
    }

    func playMovieTrailer() {
        guard let movieTrailerUrl = self.movie?.videos.first(where: { $0.site == .some(.youTube) })?.youTubeUrl else { return }

        let config = SFSafariViewController.Configuration()

        let sfSafariViewController = SFSafariViewController(url: movieTrailerUrl, configuration: config)

        let response = MovieDetails.PlayMovie.Response(webViewController: sfSafariViewController)
        presenter?.presentPlayMovieTrailer(response)
    }
}
