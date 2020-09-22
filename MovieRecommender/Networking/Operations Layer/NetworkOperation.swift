//
//  NetworkOperation.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

public struct EmptyBody: Encodable {}
public struct EmptyResponseModel: Decodable {}

public protocol NetworkOperation {
    associatedtype Output

    /// Request to execute
    var request: Request { get }

    /// Execute request in a passed network service.
    ///
    /// - Parameter service: NetworkService
    /// - Parameter completion: Tries to transform response into a client defined model.
    func execute(in service: NetworkService, completion: @escaping (Swift.Result<Output, Error>) -> Void)
}

public extension NetworkOperation where Output: Decodable {
    func execute(in service: NetworkService, completion: @escaping (Swift.Result<Output, Error>) -> Void) {
        service.executeRequest(request, completion: { result in
            switch result {
                case let .success(response):
                    do {
                        let responseModel = try JSONDecoder().decode(Output.self, from: response.rawResponse)
                        completion(.success(responseModel))
                    } catch {
                        completion(.failure(error))
                    }
                case let .failure(error):
                    completion(.failure(error))
            }
        })
    }
}
