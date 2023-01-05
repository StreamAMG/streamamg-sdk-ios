//
//  AMGPlayKit+Tracks.swift
//  StreamAMG
//
//  Created by Franco Driansetti on 11/11/2022.
//

import Foundation
import PlayKit

extension AMGPlayKit {
    
    /// Serves caption list for the selected video entry ID.
    /// - Parameters:
    ///   - server: StreamAMG server URL
    ///   - entryID: Video Entry ID
    ///   - partnerID: Video Partner ID
    ///   - ks: Key Session protection
    ///   - completion: returns the list of availabe subtitles {CaptionAssetElement}
    func fetchTracksData(server: String, entryID: String, partnerID: Int, ks: String?, completion: @escaping ((CaptionAssetElement?) -> Void)) {
     
            guard let validURL = URL(string: "\(server)/api_v3/?service=multirequest&format=1&1:service=session&1:action=startWidgetSession&1:widgetId=\(partnerID)&2:ks=\(ks ?? "")&2:service=caption_captionasset&2:action=list&2:filter:entryIdEqual=\(entryID)")
            else {
                completion(nil)
                return
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        var urlRequest = URLRequest(url: validURL)
        urlRequest.httpMethod = "GET"
        let request = session.dataTask(with: urlRequest) {data, response, error in
            do {
                if let data = data {
                    let responseObject = try JSONDecoder().decode([CaptionAssetElement].self, from: data)
                    completion(responseObject.last)
                } else {
                    completion(nil)
                }
            } catch {
                print(error)
                completion(nil)
            }
        }
        request.resume()
        
    }
    

    
}

