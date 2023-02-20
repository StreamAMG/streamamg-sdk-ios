//
//  StreamAMGSDK+Networking.swift
//  StreamSDK-Core
//
//  Created by Mike Hall on 20/01/2021.
//

import Foundation

extension StreamAMGSDK{
    
    public static func sendRequest<T: Codable>(_ url: String, component: StreamSDKComponent = .CORE, completion: ((Result<T, StreamAMGError>) -> Void)?) {
        logNetworkCore(data: "URL: \(url)")
        guard let validURL = URL(string: url.replacingOccurrences(of: " ", with: "%20")) else {
            logErrorCore(data: "Invalid URL requested...... \(url)")
            let error = StreamAMGError.init(message: "Invalid URL requested - \(url)")
            completion?(.failure(error))
            return
        }
        let session = URLSession(configuration: .default)
        var urlRequest = URLRequest(url: validURL)
        urlRequest.httpMethod = "GET"
        let request = session.dataTask(with: urlRequest) {data, response, error in
            if let err = error {
                DispatchQueue.main.async {
                    let streamError = StreamAMGError.init(message: err.localizedDescription)
                    if let httpResponse = response as? HTTPURLResponse {
                        streamError.code = httpResponse.statusCode
                    }
                    StreamSDKLogger.instance.logError(entry: streamError.getMessages(), tag: "STREAMSDK - \(component.rawValue)")
                    completion?(.failure(streamError))
                }
                return
            }
            
            guard response != nil, let data = data else {
                return
            }

            DispatchQueue.main.async {
                do {
                    let responseObject = try JSONDecoder().decode(T.self, from: data)
                    completion?(.success(responseObject))
                } catch {
                    let streamError = StreamAMGError.init(message: error.localizedDescription)
                    if let httpResponse = response as? HTTPURLResponse {
                        streamError.code = httpResponse.statusCode
                    }
                    StreamSDKLogger.instance.logError(entry: error.localizedDescription, tag: "STREAMSDK - \(component.rawValue)")
                    completion?(.failure(streamError))
                }
            }
            
        }
        request.resume()
    }
    
    public static func sendPostRequest<T: Codable>(_ url: String, body: Data?, component: StreamSDKComponent = .CORE, completion: ((Result<T, StreamAMGError>) -> Void)?) {
        logNetworkCore(data: "URL: \(url)")
        guard let validURL = URL(string: url.replacingOccurrences(of: " ", with: "%20")) else {
            logErrorCore(data: "Invalid URL requested...... \(url)")
            let error = StreamAMGError.init(message: "Invalid URL requested - \(url)")
            completion?(.failure(error))
            return
        }
        let session = URLSession(configuration: .default)
        var urlRequest = URLRequest(url: validURL)
        urlRequest.httpMethod = "POST"
        if let body = body {
            urlRequest.httpBody = body
        }
        let request = session.dataTask(with: urlRequest) {data, response, error in
            if let err = error {
                DispatchQueue.main.async {
                    let streamError = StreamAMGError.init(message: err.localizedDescription)
                    if let httpResponse = response as? HTTPURLResponse {
                        streamError.code = httpResponse.statusCode
                    }
                    StreamSDKLogger.instance.logError(entry: streamError.getMessages(), tag: "STREAMSDK - \(component.rawValue)")
                    completion?(.failure(streamError))
                }
                return
            }
            
            guard response != nil, let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let responseObject = try JSONDecoder().decode(T.self, from: data)
                    completion?(.success(responseObject))
                } catch {
                    let streamError = StreamAMGError.init(message: error.localizedDescription)
                    if let httpResponse = response as? HTTPURLResponse {
                        streamError.code = httpResponse.statusCode
                    }
                    StreamSDKLogger.instance.logError(entry: error.localizedDescription, tag: "STREAMSDK - \(component.rawValue)")
                    completion?(.failure(streamError))
                }
            }
            
        }
        request.resume()
    }
    
    public static func sendPatchRequest<T: Codable>(_ url: String, body: Data?, component: StreamSDKComponent = .CORE, completion: ((Result<T, StreamAMGError>) -> Void)?) {
        logNetworkCore(data: "URL: \(url)")
        guard let validURL = URL(string: url.replacingOccurrences(of: " ", with: "%20")) else {
            logErrorCore(data: "Invalid URL requested...... \(url)")
            let error = StreamAMGError.init(message: "Invalid URL requested - \(url)")
            completion?(.failure(error))
            return
        }
        let session = URLSession(configuration: .default)
        var urlRequest = URLRequest(url: validURL)
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            urlRequest.httpBody = body
        }
        let request = session.dataTask(with: urlRequest) {data, response, error in
            if let err = error {
                DispatchQueue.main.async {
                    let streamError = StreamAMGError.init(message: err.localizedDescription)
                    if let httpResponse = response as? HTTPURLResponse {
                        streamError.code = httpResponse.statusCode
                    }
                    StreamSDKLogger.instance.logError(entry: streamError.getMessages(), tag: "STREAMSDK - \(component.rawValue)")
                    completion?(.failure(streamError))
                }
                return
            }
            
            guard response != nil, let data = data else {
                return
            }
            //            let contents = String(data: data, encoding: .ascii)
            //            print(contents)
            DispatchQueue.main.async {
                do {
                    let responseObject = try JSONDecoder().decode(T.self, from: data)
                    completion?(.success(responseObject))
                } catch {
                    let streamError = StreamAMGError.init(message: error.localizedDescription)
                    if let httpResponse = response as? HTTPURLResponse {
                        streamError.code = httpResponse.statusCode
                    }
                    StreamSDKLogger.instance.logError(entry: error.localizedDescription, tag: "STREAMSDK - \(component.rawValue)")
                    completion?(.failure(streamError))
                }
            }
            
        }
        request.resume()
    }
    
}
