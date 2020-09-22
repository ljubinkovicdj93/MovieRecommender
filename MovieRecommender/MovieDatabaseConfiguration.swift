//
//  MovieDatabaseConfiguration.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

class MovieDatabaseConfiguration {
    struct Constants {
        static let movieDbConfigurationKey: String = "movieDbConfigurationKey"
    }

    var movieConfiguration: GetMovieDatabaseConfigurationResponseModel?

    private init() {}

    static let shared = MovieDatabaseConfiguration()

    var apiConfiguration: NetworkServiceConfiguration {
        do {
            return try NetworkServiceConfiguration.loadFromPlist(fileName: "Settings")
        } catch {
            // This shouldn't happen. If it does, it's the programmer's fault.
            fatalError(error.localizedDescription)
        }
    }
}

class MovieDbUrlRequestBuilder: URLRequestBuilder {
    override func buildUrlRequest(configuration: NetworkServiceConfiguration, request: Request) throws -> URLRequest {
        guard let apiKey = configuration.apiKey else { fatalError("NO API KEY FOUND!") }

        let movieDbUrlRequest = try super.buildUrlRequest(configuration: configuration, request: request).appended(queryItem: URLQueryItem(name: "api_key", value: apiKey))

        print("🟢🟢🟢 Movie DB URLRequest: \(movieDbUrlRequest.curlString) 🟢🟢🟢")

        return movieDbUrlRequest
    }
}
