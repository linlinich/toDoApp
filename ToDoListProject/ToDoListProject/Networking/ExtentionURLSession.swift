//
//  ExtentionURLSession.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 08.07.2023.
//

import Foundation
extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?
        return try await withCheckedThrowingContinuation({ continuation in
            task = self.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print("Ошибка \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
                guard let data = data,
                        let response = response
                else {
                    print("Ошибка")
                    continuation.resume(throwing: URLError(.unknown))
                    return
                }
                DispatchQueue.main.async {
                    continuation.resume(returning: (data, response))
                }
            }
            Task.isCancelled ? task?.cancel() : task?.resume()
        })
    }
}
