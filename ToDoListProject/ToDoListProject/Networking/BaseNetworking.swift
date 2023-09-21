//
//  BaseNetworking.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 06.07.2023.
//

import Foundation

class RequestProcessor: NetworkingService {
    static func makeUrl(id: String? = nil) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "beta.mrdekk.ru"
        components.path = "/todobackend/list"
        if let elementId = id {
            components.path = "/todobackend/list/\(elementId)"
        }
        guard let url = components.url else {
            throw RequestProcessorError.wrongUrl(components)
        }
        return url
    }
    
    static func requestToTheServer(
        urlSession: URLSession = .shared,
        url: URL,
        method: HttpMethod,
        body: Data? = nil
    ) async throws -> (Data, Int) {
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 60.0)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(tocken)", forHTTPHeaderField: "Authorization")
        if method != .get {
            request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
        }
        if method != .delete && method != .get {
            request.httpBody = body
        }
        let (data, responce) = try await urlSession.data(for: request)
        guard let responce = responce as? HTTPURLResponse else {
            throw RequestProcessorError.unexpectedResponse(responce)
        }
    
        return (data, responce.statusCode)
    }
    
    private static let tocken = "unnagging"
    static var revision: Int32 = 0
    private static let httpStatusCodeSucsess = 200..<300
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum RequestProcessorError: Error {
    case unexpectedResponse(URLResponse)
    case wrongUrl(URLComponents)
    case failedResponce(HTTPURLResponse)
}
