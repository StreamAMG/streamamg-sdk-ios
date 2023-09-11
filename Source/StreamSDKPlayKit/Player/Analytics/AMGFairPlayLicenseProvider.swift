//
//  StreamAMGFairPlayLicenseProvider.swift
//  playkitdemo
//
//  Created by Sam Easterby-Smith on 02/12/2020.
//


import Foundation
import PlayKit
import AVFoundation



public class AMGFairPlayLicenseProvider: FairPlayLicenseProvider {
    
    public func getContentId(request: URLRequest) -> String? {
        // Extract the URI attribute from the request's URL
        return request.url?.absoluteString
    }
    
    public static let sharedInstance = AMGFairPlayLicenseProvider()
    
    public func getLicense(spc: Data, contentId: String, requestParams: PKRequestParams, callback: @escaping (Data?, TimeInterval, Error?) -> Void) {
        var request = URLRequest(url: requestParams.url)
        
        // uDRM requires application/octet-stream as the content type.
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // Also add the user agent
        request.setValue(PlayKitManager.userAgent, forHTTPHeaderField: "User-Agent")
        
        // Add other optional headers
        if let headers = requestParams.headers {
            for (header, value) in headers {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }
        
        request.httpBody = spc.base64EncodedData()
        request.httpMethod = "POST"
        
        PKLog.debug("Sending SPC to server")
        let startTime = Date.timeIntervalSinceReferenceDate
        let dataTask = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                callback(nil, 0, FPSError.serverError(error, requestParams.url))
                return
            }
            
            let endTime: Double = Date.timeIntervalSinceReferenceDate
            PKLog.debug("Got response in \(endTime-startTime) sec")
            
            guard let data = data, data.count > 0 else {
                callback(nil, 0, FPSError.malformedServerResponse)
                return
            }
            
            let offlineExpiry: TimeInterval = 7*24*60*60
            callback(data, offlineExpiry, nil)
            
        }
        dataTask.resume()
    }
}
