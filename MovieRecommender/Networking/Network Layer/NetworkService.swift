//
//  NetworkService.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

public typealias Headers = [String: String]
public typealias JSON = [String: Any]

public struct HeadersFactory {
    static let defaultHeaders = [
        "Content-Type": "application/json",
        "Accept": "*/*"
    ]

    static func bearerTokenHeader(_ token: String) -> Headers {
        return ["Authorization": "Bearer \(token)"]
    }
}

public struct NetworkServiceConfiguration: Codable {
    var scheme: String = "https"
    let baseUrl: String
    var apiKey: String?
    var commonHeaders: Headers = HeadersFactory.defaultHeaders

    public static func loadFromPlist(fileName: String) throws -> NetworkServiceConfiguration {
        do {
            return try NetworkServiceConfigurationPreferencesLoader.load(plistFileName: fileName)
        } catch {
            throw error
        }
    }
}

private struct NetworkServiceConfigurationPreferencesLoader {
    private enum NetworkServiceConfigurationPreferencesLoaderError: Error, LocalizedError {
        case noPlistFileFound(String)
        case noDataInPlistFile
        case unableToConvertToDictionary
    }

    static func getPropertyListData(plistFileName: String) throws -> Data {
        guard let plistPath = Bundle.main.path(forResource: plistFileName, ofType: "plist") else { throw NetworkServiceConfigurationPreferencesLoaderError.noPlistFileFound("\(plistFileName).plist")}
        guard let plistXML = FileManager.default.contents(atPath: plistPath) else { throw NetworkServiceConfigurationPreferencesLoaderError.noDataInPlistFile }

        return plistXML
    }

    static func load(plistFileName: String) throws -> NetworkServiceConfiguration {
        do {
            let plistName: String
            if plistFileName.components(separatedBy: ".").count == 1 {
                plistName = plistFileName
            } else {
                plistName = plistFileName.components(separatedBy: ".").first ?? ""
            }

            let decoder = PropertyListDecoder()
            let data = try getPropertyListData(plistFileName: plistName)
            let preferences = try decoder.decode(NetworkServiceConfiguration.self, from: data)

            return preferences
        } catch {
            throw error
        }
    }
}

public protocol NetworkService {
    var configuration: NetworkServiceConfiguration { get set }

    func executeRequest(_ request: Request, completion: @escaping (Swift.Result<Response, Error>) -> Void)
    func cancel()
}

public class URLNetworkService: NSObject, NetworkService {
    enum URLNetworkServiceError: Error, LocalizedError {
        case noDataReceived
        case invalidUrlResponse
        case badRequest
        case unauthorized
        case paymentRequired
        case forbidden
        case notFound
        case serverError
        case unknown(Int)
    }

    public var configuration: NetworkServiceConfiguration
    public let session: URLSession
    private var currentTask: URLSessionDataTask?
    private let urlRequestBuilder: URLRequestBuilder

    public init(configuration: NetworkServiceConfiguration,
                urlRequestBuilder: URLRequestBuilder = URLRequestBuilder(),
                sessionConfiguration: URLSessionConfiguration = .default) {
        self.configuration = configuration
        self.session = URLSession(configuration: sessionConfiguration)
        self.urlRequestBuilder = urlRequestBuilder
    }

    public func executeRequest(_ request: Request, completion: @escaping (Swift.Result<Response, Error>) -> Void) {
        guard var urlRequest = try? urlRequestBuilder.buildUrlRequest(configuration: configuration, request: request) else { return }

        request.onIntercept?(&urlRequest)
        print("\n🟢🟢🟢Sending request:\n\(urlRequest.curlString)\n🟢🟢🟢\n")

        currentTask = session.dataTask(with: urlRequest) { data, response, error in
            if let err = error {
                completion(.failure(err))
                return
            }

            guard let responseData = data else {
                completion(.failure(URLNetworkServiceError.noDataReceived))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(URLNetworkServiceError.invalidUrlResponse))
                return
            }

            print("\n🟢🟢🟢 Response:\n\(httpResponse)\n🟢🟢🟢\n")

            switch httpResponse.statusCode {
                case 200...299:
                    let response = Response(httpUrlResponse: httpResponse,
                                            originRequest: request,
                                            rawResponse: responseData)
                    completion(.success(response))
                case 400:
                    completion(.failure(URLNetworkServiceError.badRequest))
                case 401:
                    completion(.failure(URLNetworkServiceError.unauthorized))
                case 402:
                    completion(.failure(URLNetworkServiceError.paymentRequired))
                case 403:
                    completion(.failure(URLNetworkServiceError.forbidden))
                case 404:
                    completion(.failure(URLNetworkServiceError.notFound))
                case 500...599:
                    completion(.failure(URLNetworkServiceError.serverError))
                default:
                    completion(.failure(URLNetworkServiceError.unknown(httpResponse.statusCode)))
            }
        }

        currentTask?.resume()
    }

    public func cancel() {
        currentTask?.cancel()
    }
}

public extension URLRequest {
    /**
     Returns a cURL command representation of this URL request.
     */
    var curlString: String {
        guard let url = url else { return "" }
        var baseCommand = #"curl "\#(url.absoluteString)""#

        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let method = httpMethod, method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }

}

public class URLRequestBuilder: NSObject {
    private enum URLRequestBuilderError: Error, LocalizedError {
        case cannotBuildValidUrl(schema: String, host: String, path: String, queryItems: [URLQueryItem])
    }

    func buildUrlRequest(configuration: NetworkServiceConfiguration, request: Request) throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = configuration.scheme
        urlComponents.host = configuration.baseUrl
        urlComponents.path = request.path.addForwardSlashPrefixIfNeeded().removeForwardSlashSuffixIfNeeded()

        if case let .url(queryItems) = request.parameters {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            throw URLRequestBuilderError.cannotBuildValidUrl(
                schema: urlComponents.scheme ?? .empty,
                host: urlComponents.host ?? .empty,
                path: urlComponents.path,
                queryItems: urlComponents.queryItems ?? []
            )
        }

        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        urlRequest.httpMethod = request.method.name

        configuration.commonHeaders.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        request.headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }

        if case let .jsonBody(json) = request.parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            } catch {
                throw error
            }
        }

        return urlRequest
    }
}
