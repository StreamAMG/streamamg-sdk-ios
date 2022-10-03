//
//  AMGPlayKit+Bitrate.swift
//  StreamAMG
//
//  Created by Mike Hall on 24/11/2021.
//


import Foundation

extension AMGPlayKit {
    
    func fetchContextData(completion: @escaping ((MediaContext?) -> Void)) {
        if let med = currentMedia, let server = med.serverURL{
            guard let validURL = URL(string: "\(server)/api_v3/?service=baseEntry&action=getContextData&entryId=\(med.entryID)&\(validKS(ks: med.ks, trailing: true))contextDataParams:objectType=KalturaEntryContextDataParams&contextDataParams:flavorTags=all&format=1")
            else {
                completion(nil)
                return
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        var urlRequest = URLRequest(url: validURL)
        urlRequest.httpMethod = "POST"
        let request = session.dataTask(with: urlRequest) {data, response, error in
            do {
                if let data = data {
                    let responseObject = try JSONDecoder().decode(MediaContext.self, from: data)
                    completion(responseObject)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        request.resume()
        }
    }
    
    public func setBitrateAuto() {
        setMaximumBitrate(bitrate: listBitrate?.last)
    }
    
    public func setMaximumBitrate(bitrate: FlavorAsset?){
        if let media = currentMedia {
            loadMedia(media: media, mediaType: currentMediaType, startPosition: Int64(player?.currentTime ?? 0), bitrate: bitrate)
        }
    }
    
    @available(*, deprecated, message: "Use the new setMaximumBitrate(bitrate: FlavorAsset?) method")
    public func setMaximumBitrate(bitrate: Double){
        player?.settings.network.preferredPeakBitRate = bitrate
    }
    
    func updateBitrateSelector(completion: @escaping (([FlavorAsset]?) -> Void)) {
        fetchContextData {data in
            if let data = data {
                self.controlUI?.createBitrateSelector(withBitrateList: data.fetchBitrates())
                completion(data.fetchBitrates())
            } else {
                self.controlUI?.createBitrateSelector(withBitrateList: [])
                completion(nil)
            }
        }
    }
    
}
