//
//  AMGPlayKit+StandardCasting.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 01/06/2021.
//

import Foundation
import MediaPlayer

extension AMGPlayKit: URLSessionTaskDelegate {
    
    public func castingURL(format: AMGMediaFormat = .HLS, completion: @escaping ((URL?) -> Void)) {
        castingCompletion = completion
        castingURL = nil
        switch format {
        case .MP4:
            if let med = currentMedia, let server = med.serverURL, let asset = URL(string: "\(server)/p/\(med.partnerID)/sp/0/playManifest/entryId/\(med.entryID)/format/url/\(validKS(ks: med.ks))protocol/https/video/mp4"){
                getCastingURL(url: asset.absoluteString)
            } else {
                completion(nil)
            }
            break
        case .HLS:
            if let med = currentMedia, let server = med.serverURL, let asset = URL(string: "\(server)/p/\(med.partnerID)/sp/0/playManifest/entryId/\(med.entryID)/format/applehttp/\(validKS(ks: med.ks))protocol/http/manifest.m3u8"){
                getCastingURL(url: asset.absoluteString)
                //   return asset
            } else {
                completion(nil)
            }
            break
        }
    }
    
    public func castingURL(server: String, partnerID: Int, entryID: String, ks: String? = nil, format: AMGMediaFormat = .HLS, completion: @escaping ((URL?) -> Void)) {
        castingCompletion = completion
        castingURL = nil
        switch format {
        case .MP4:
            if let asset = URL(string: "\(server)/p/\(partnerID)/sp/0/playManifest/entryId/\(entryID)/format/url/\(validKS(ks: ks))protocol/https/video/mp4"){
                getCastingURL(url: asset.absoluteString)
            } else {
                completion(nil)
            }
            break
        case .HLS:
            if let asset = URL(string: "\(server)/p/\(partnerID)/sp/0/playManifest/entryId/\(entryID)/format/applehttp/\(validKS(ks: ks))protocol/http/manifest.m3u8"){
                getCastingURL(url: asset.absoluteString)
            } else {
                completion(nil)
            }
            break
        }
    }
    
    private func validKS(ks: String?)-> String {
        if let ks = ks {
            return "ks/\(ks)/"
        }
        return ""
    }
    
    func sendCastingURL(url: String?) {
        guard let url = url, let urlToCast = URL(string: url) else {
            return
        }
        if castingURL == nil {
            castingURL = urlToCast
            castingCompletion?(urlToCast)
        }
    }
    
    
    func getCastingURL(url: String) {
        
        print( "URL: \(url)")
        guard let validURL = URL(string: url.replacingOccurrences(of: " ", with: "%20")) else {
            return
        }
        initialCastingURL = validURL.absoluteString
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        var urlRequest = URLRequest(url: validURL)
        urlRequest.httpMethod = "GET"
        let request = session.dataTask(with: urlRequest) {data, response, error in
            if (response as? HTTPURLResponse) != nil {
                self.sendCastingURL(url: url)
            }
        }
        request.resume()
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let location = response.allHeaderFields["Location"] as? String {
            sendCastingURL(url: location)
        } else {
            sendCastingURL(url: initialCastingURL)
        }
    }
    
}
