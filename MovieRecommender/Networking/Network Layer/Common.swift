//
//  Common.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

// TODO: Add other, although less used, methods.
public enum HttpMethod: String {
    case post
    case get
    case put
    case delete
    case patch

    public var name: String {
        return self.rawValue.uppercased()
    }
}

public extension String {
    static let empty = ""
    static let forwardSlash = "/"

    func addForwardSlashPrefixIfNeeded() -> String {
        guard !self.hasPrefix(.forwardSlash) else { return self }
        return "\(String.forwardSlash)\(self)"
    }

    func removeForwardSlashSuffixIfNeeded() -> String {
        guard self.hasSuffix(.forwardSlash) else { return self }
        return String(self.dropLast())
    }
}

public extension URLRequest {
    func appended(queryItem: URLQueryItem) -> URLRequest {
        guard let url = self.url else { return self }

        var updatedUrlRequest = self
        updatedUrlRequest.url = url.appendingQueryItem(queryItem)

        return updatedUrlRequest
    }
}

extension URL {

    func appendingQueryItem(_ queryItem: URLQueryItem) -> URL {

        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }
}
