//
//  AuthInterceptor.swift
//  FTDriver
//
//  Created by Tan Dat on 8/9/24.
//

import Alamofire

class AuthInterceptor: RequestInterceptor {
    
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        adaptedRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        completion(.success(adaptedRequest))
    }
    
    func retry(_ request: Request, for session: Session, with retryError: Error, completion: @escaping (RetryResult) -> Void) {
        // Logic for retrying a request if needed
        completion(.doNotRetry)
    }
}

