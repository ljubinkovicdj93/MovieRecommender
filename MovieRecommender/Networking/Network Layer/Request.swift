//
//  Request.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

public enum RequestParameters {
    case empty
    case jsonBody(JSON)
    case url([URLQueryItem])
}

public protocol Request {
    /// Will get called before each request gets called.
    /// This can be used to call refresh token for example, before calling the main request.
    var onPreExecute: (() -> Void)? { get }
    var onIntercept: ((inout URLRequest) -> Void)? { get }

    var path: String { get }
    var method: HttpMethod { get }

    /// Uses common headers by default, defined inside the NetworkEnvironment, but can be overriden for a specific request.
    var headers: Headers { get }

    var parameters: RequestParameters { get }
}

public extension Request {
    var onPreExecute: (() -> Void)? {
        return nil
    }

    var onIntercept: ((inout URLRequest) -> Void)? {
        return nil
    }
}

