//
//  MovieDetailsModels.swift
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

struct MovieDetails {
    // MARK: Use cases

    struct InitialState {
        struct Response {
            let movie: Movie
        }

        struct ViewModel {
            let movieThumbnailStyle: ViewStyle<UIImageView>
            let movieTitleStyle: ViewStyle<UILabel>
            let movieSummaryStyle: ViewStyle<UILabel>
        }
    }

    struct PlayMovie {
        struct Response {
            let webViewController: SFSafariViewController
        }

        typealias ViewModel = Response
    }
}
