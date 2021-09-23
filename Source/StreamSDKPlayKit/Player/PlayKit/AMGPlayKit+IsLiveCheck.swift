//
//  AMGPlayKit+IsLiveCheck.swift
//  StreamAMGSDK
//
//  Created by Mike Hall on 17/09/2021.
//

import Foundation

extension AMGPlayKit {
    func isLive(completion: @escaping ((Bool) -> Void)) {
        if let med = currentMedia, let server = med.serverURL{
            guard let validURL = URL(string: "\(server)/api_v3/?service=liveStream&action=islive&id=\(med.entryID)&protocol=applehttp&format=1") else {
                completion(false)
                return
        }
            print("AMGLIVE: \(validURL.absoluteString)")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        var urlRequest = URLRequest(url: validURL)
        urlRequest.httpMethod = "POST"
        let request = session.dataTask(with: urlRequest) {data, response, error in
            if let data = data, let resp = String(data: data, encoding: .utf8) {
                if resp.lowercased() == "true" {
                    completion(true)
                    return
                }
            }
            completion(false)
        }
        request.resume()
        }
    }
}
