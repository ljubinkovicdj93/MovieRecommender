//
//  ClientRequests.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

struct GetMovieDatabaseConfigurationOperation: NetworkOperation {
    typealias Output = GetMovieDatabaseConfigurationResponseModel

    var request: Request {
        return ConfigurationRequests.getConfiguration
    }
}

struct GetMovieDatabaseConfigurationResponseModel: Codable {
    let images: ImageConfigurationResponseModel

    var sizeUrlString: String? {
        guard let largestImageSizePath = images.posterSizes.last else { return nil }

        return "\(images.baseUrl.absoluteString)\(largestImageSizePath)"
    }
}

struct ImageConfigurationResponseModel: Codable {
    let baseUrl: URL
    let posterSizes: [String]

    enum CodingKeys: String, CodingKey {
        case baseUrl = "base_url"
        case posterSizes = "poster_sizes"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        baseUrl = try values.decode(URL.self, forKey: .baseUrl)

        posterSizes = try values.decode([String].self, forKey: .posterSizes)
    }
}

struct GetVideosForMovieOperation: NetworkOperation {
    typealias Output = GetVideosForMovieResponseModel

    let movie: Movie

    var request: Request {
        return MovieRequests.getMovieVideos(movie)
    }
}

struct GetPopularMoviesOperation: NetworkOperation {
    typealias Output = GetPopularMoviesResponseModel

    var request: Request {
        return MovieRequests.getPopularMovies
    }
}

struct GetPopularMoviesResponseModel: Decodable {
    let popularMovies: [Movie]

    enum CodingKeys: String, CodingKey {
        case popularMovies = "results"
    }
}

struct GetVideosForMovieResponseModel: Decodable {
    let movieId: Int
    let videos: [Video]

    enum CodingKeys: String, CodingKey {
        case movieId = "id"
        case videos = "results"
    }
}


/*
 {
 "id": 694919,
 "popularity": 2185.128,
 "video": false,
 "vote_count": 0,
 "poster_path": "/6CoRTJTmijhBLJTUNoVSUNxZMEI.jpg",
 "adult": false,
 "backdrop_path": "/gYRzgYE3EOnhUkv7pcbAAsVLe5f.jpg",
 "original_language": "en",
 "original_title": "Money Plane",
 "genre_ids": [
 28
 ],
 "title": "Money Plane",
 "vote_average": 0,
 "overview": "A professional thief with $40 million in debt and his family's life on the line must commit one final heist - rob a futuristic airborne casino filled with the world's most dangerous criminals.",
 "release_date": "2020-09-29"
 }
 ,...
 **/
struct Movie: Decodable {
    let id: Int
    let popularity: Double
    let title: String
    let summary: String
    let releaseDate: Date?
    let hasVideo: Bool
    let posterImagePath: String?

    var videos: [Video] = []

    var userDefaultsStorable: UserDefaultsStorable = UserDefaults.standard
    var imageUrl: URL? {
        guard let config: GetMovieDatabaseConfigurationResponseModel = try? userDefaultsStorable.getObject(forKey: "movieDbConfigurationKey") else { return nil }
        guard let prefixUrl = URL(string: config.sizeUrlString ?? .empty),
              let posterImgPath = self.posterImagePath
        else { return nil }

        return prefixUrl.appendingPathComponent(posterImgPath, isDirectory: false)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case popularity
        case title
        case summary = "overview"
        case releaseDate = "release_date"
        case hasVideo = "video"
        case posterImagePath = "poster_path"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        popularity = try values.decode(Double.self, forKey: .popularity)
        title = try values.decode(String.self, forKey: .title)
        summary = try values.decode(String.self, forKey: .summary)

        let dateString = try values.decode(String.self, forKey: .releaseDate)
        releaseDate = DateFormatter.dashFormat.date(from: dateString)

        hasVideo = try values.decode(Bool.self, forKey: .hasVideo)
        posterImagePath = try values.decode(String.self, forKey: .posterImagePath)
    }
}

/*
 {
 "id": "57817ada9251417c28000b02",
 "iso_639_1": "en",
 "iso_3166_1": "US",
 "key": "827FNDpQWrQ",
 "name": "Interstellar - Teaser Trailer - Official Warner Bros. UK",
 "site": "YouTube",
 "size": 1080,
 "type": "Trailer"
 }
 **/
public enum VideoType: String, Decodable {
    case featurette = "Featurette"
    case trailer = "Trailer"
}

public enum VideoSite: String, Decodable {
    case youTube = "YouTube"
}

public struct Video: Decodable {
    let id: String
    let key: String
    let name: String
    let site: VideoSite?
    let size: Int
    let type: VideoType?

    var youTubeUrl: URL? {
        guard let url = URL(string: "https://www.youtube.com/watch?v=\(key)") else { return nil }

        return url
    }

    enum CodingKeys: String, CodingKey {
        case id
        case key
        case name
        case site
        case size
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        key = try values.decode(String.self, forKey: .key)
        name = try values.decode(String.self, forKey: .name)
        size = try values.decode(Int.self, forKey: .size)

        let videoSite = try values.decode(String.self, forKey: .site)
        site = VideoSite(rawValue: videoSite)

        let videoType = try values.decode(String.self, forKey: .type)
        type = VideoType(rawValue: videoType)
    }
}

enum ConfigurationRequests: Request {

    case getConfiguration

    var path: String {
        switch self {
            case .getConfiguration:
                return "/3/configuration"
        }
    }

    var method: HttpMethod {
        switch self {
            case .getConfiguration:
                return .get
        }
    }

    var headers: Headers {
        return HeadersFactory.bearerTokenHeader(movieDbAccessToken)
    }

    var parameters: RequestParameters {
        return .empty
    }
}

enum MovieRequests: Request {

    case getPopularMovies
    case getMovieVideos(_ movie: Movie)

    public var headers: Headers {
        return HeadersFactory.bearerTokenHeader(movieDbAccessToken)
    }

    public var parameters: RequestParameters {
        switch self {
            case .getPopularMovies, .getMovieVideos:
                return .empty
        }
    }

    public var path: String {
        switch self {
            case .getPopularMovies:
                return "/3/movie/popular"
            case let .getMovieVideos(movie):
                return "/3/movie/\(movie.id)/videos"
        }
    }

    public var method: HttpMethod {
        switch self {
            case .getPopularMovies, .getMovieVideos:
                return .get
        }
    }
}
