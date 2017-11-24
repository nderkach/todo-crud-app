//
//  CMXAPI.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/6/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import Siesta
import JWTDecode
import KeychainAccess
import Alamofire

// WARNING: add your API URL here
let baseURL = "http://myawesomeapi.com"

let CMXAPI = _CMXAPI()

class _CMXAPI {
    
    // MARK: - Configuration

    let keychain = Keychain(server: baseURL, protocolType: .https)

    static let sharedManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        return SessionManager(configuration: configuration)
    }()
    
    private let service = Service(
        baseURL: baseURL,
        standardTransformers: [.text, .image],
        networking: sharedManager)

    private var refreshTimer: Timer?
    private var refreshToken: String? {
        didSet {
            keychain["refresh_token"] = refreshToken
        }
    }
    
    public var authToken: String? {
        didSet {
            service.invalidateConfiguration()

            keychain["auth_token"] = authToken

            guard let token = authToken else { return }
            
            let jwt = try? JWTDecode.decode(jwt: token)
            tokenExpiryDate = jwt?.expiresAt
        }
    }
    
    public private(set) var tokenExpiryDate: Date? {
        didSet {
            guard let tokenExpiryDate = tokenExpiryDate else { return }
            
            let timeToExpire = tokenExpiryDate.timeIntervalSinceNow
            
            // try to refresh JWT token before the expiration time
            let timeToRefresh = Date(timeIntervalSinceNow: timeToExpire * 0.9)
            
            refreshTimer = Timer.scheduledTimer(withTimeInterval: timeToRefresh.timeIntervalSinceNow, repeats: false) { _ in

                guard let _ = self.refreshToken else {
                    return
                }
                
                CMXAPI.refreshAuth()
            }
        }
    }
        
    fileprivate init() {
        // –––––– Global configuration ––––––

        #if DEBUG
            LogCategory.enabled = [.network]
        #endif
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .secondsSince1970

        refreshToken = keychain["refresh_token"]
        authToken = keychain["auth_token"]
        
        service.configure("**") {
            if let authToken = self.authToken {
                $0.headers["Cookie"] = "ACCESS_TOKEN=\(authToken)"
            }

            // Retry requests on auth failure
            $0.decorateRequests {
                self.refreshTokenOnAuthFailure(request: $1)
            }

            // Decode API error messages
            $0.pipeline[.cleanup].add(
                CMXErrorMessageExtractor(jsonDecoder: jsonDecoder))
        }
        
        // –––––– Mapping from specific paths to models ––––––
        
        service.configureTransformer("/me") {
            try jsonDecoder.decode(User.self, from: $0.content)
        }
        
        service.configureTransformer("/access-tokens", requestMethods: [.post]) {
            try jsonDecoder.decode([String: String].self, from: $0.content)
        }

        service.configureTransformer("/access-tokens/refresh") {
            try jsonDecoder.decode([String: String].self, from: $0.content)
        }

        service.configureTransformer("/ideas", requestMethods: [.get]) {
            try jsonDecoder.decode([Idea].self, from: $0.content)
        }

        service.configureTransformer("/ideas", requestMethods: [.post]) {
            try jsonDecoder.decode(Idea.self, from: $0.content)
        }

        service.configureTransformer("/users", requestMethods: [.post]) {
            try jsonDecoder.decode([String: String].self, from: $0.content)
        }
    }
    
    // MARK: - Resource Accessors
    
    func profile() -> Resource {
        return service.resource("/me")
    }
    
    func ideas() -> Resource {
        return service.resource("/ideas")
    }

    func addIdea(_ idea: Idea) -> Siesta.Request {
        let request = service.resource("/ideas")
            .request(.post, json: ["content": idea.content, "impact": idea.impact, "ease": idea.ease, "confidence": idea.confidence])

        return request
    }

    func updateIdea(_ idea: Idea) -> Siesta.Request {
        let request = service.resource("/ideas").child(idea.id)
            .request(.put, json: ["content": idea.content, "impact": idea.impact, "ease": idea.ease, "confidence": idea.confidence])

        return request
    }
    
    func removeIdea(_ idea: Idea) -> Siesta.Request {
        let request = service.resource("/ideas")
            .child(idea.id)
            .request(.delete)
        
        return request
    }
    
    // MARK: - Authentication

    func refreshTokenOnAuthFailure(request: Siesta.Request) -> Siesta.Request {
        return request.chained {
            guard case .failure(let error) = $0.response,  // Did request fail…
                error.httpStatusCode == 401 else {           // …because of expired token?
                    return .useThisResponse                    // If not, use the response we got.
            }

            return .passTo(
                self.refreshAuth().chained {             // If so, first request a new token, then:
                    if case .failure = $0.response {           // If token request failed…
                        return .useThisResponse                  // …report that error.
                    } else {
                        return .passTo(request.repeated())       // We have a new token! Repeat the original request.
                    }
                }
            )
        }
    }
    
    func signup(email: String, password: String, name: String, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void) -> Siesta.Request {
        let request = service.resource("/users")
            .request(.post, json: ["email": email, "password": password, "name": name])
            .onSuccess { entity in
                guard let json: [String: String] = entity.typedContent() else {
                    onFailure("JSON parsing error")
                    return
                }
                
                guard let token = json["jwt"] else {
                    onFailure("JWT token missing")
                    return
                }
                
                guard let refreshToken = json["refresh_token"] else {
                    onFailure("Refresh token missing")
                    return
                }
                
                self.authToken = token
                self.refreshToken = refreshToken

                NotificationCenter.default.post(name: Notification.Name("LoggedIn"), object: nil)

                onSuccess()
            }
            .onFailure { error in
                onFailure(error.userMessage)
        }

        return request
    }
    
    func login(email: String, password: String, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void) -> Siesta.Request {
        let request = service.resource("/access-tokens")
            .request(.post, json: ["email": email, "password": password])
            .onSuccess { entity in
                guard let json: [String: String] = entity.typedContent() else {
                    onFailure("JSON parsing error")
                    return
                }
                
                guard let token = json["jwt"] else {
                    onFailure("JWT token missing")
                    return
                }
                
                guard let refreshToken = json["refresh_token"] else {
                    onFailure("Refresh token missing")
                    return
                }
                
                self.authToken = token
                self.refreshToken = refreshToken

                NotificationCenter.default.post(name: Notification.Name("LoggedIn"), object: nil)

                onSuccess()
            }
            .onFailure { (error) in
                onFailure(error.userMessage)
        }

        return request
    }
        
    @discardableResult func refreshAuth() -> Siesta.Request {
        let request = service.resource("/access-tokens/refresh")
            .request(.post, json: ["refresh_token": self.refreshToken!])
            .onSuccess { entity in
                guard let json: [String: String] = entity.typedContent() else {
                    return
                }
        
                guard let token = json["jwt"] else {
                    return
                }
        
                self.authToken = token

                NotificationCenter.default.post(name: Notification.Name("LoggedIn"), object: nil)
            }
            .onFailure { (error) in
                print(error)
        }
        return request
    }
    
    func logout() -> Siesta.Request {
        let request = service.resource("/access-tokens")
            .request(.delete, json: ["refresh_token": refreshToken])
            .onSuccess { _ in
                self.authToken = nil
                self.refreshToken = nil
                self.tokenExpiryDate = nil
                self.refreshTimer?.invalidate()
                self.service.wipeResources()
            }.onCompletion { _ in
                NotificationCenter.default.post(name: Notification.Name("Logout"), object: nil)
        }
        
        return request
    }

    func isAuthenticated() -> Bool {
        guard let _ = authToken, let _ = refreshToken else {
            return false
        }

        guard let tokenExpiryDate = tokenExpiryDate, tokenExpiryDate > Date() else {
            return false
        }

        return true
    }

    func hasCredentials() -> Bool {
        guard let _ = refreshToken else {
            return false
        }

        return true
    }
}

// MARK: - Custom Transformers

private struct CMXErrorMessageExtractor: ResponseTransformer {
    let jsonDecoder: JSONDecoder

    func process(_ response: Response) -> Response {
        guard case .failure(var error) = response,
            let errorData: Data = error.typedContent(),
            let cmxError = try? jsonDecoder.decode(
                CMXErrorEnvelope.self, from: errorData)
            else {
                return response
        }

        error.userMessage = cmxError.reason
        return .failure(error)
    }

    private struct CMXErrorEnvelope: Decodable {
        let reason: String
    }
}
