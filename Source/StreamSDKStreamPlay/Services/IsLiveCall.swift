//
//  IsLiveCall.swift
//  StreamSDKStreamPlay
//
//  Created by Mike Hall on 27/01/2021.
//

import Foundation
//import StreamAMGSDK //Required only for running tests

public protocol StreamPlayIsLiveDelegate {
    func isLiveResponseRecieved(model: StreamPlayIsLiveModel)
    func isLiveErrorRecieved(model: StreamPlayIsLiveErrorModel)
}

class IsLiveCall {
    let id: String
    let url: String
    let delegate: StreamPlayIsLiveDelegate?
    let completion: ((Result<StreamPlayIsLiveModel, StreamPlayIsLiveErrorModel>) -> Void)?
    
    var nextPoll: TimeInterval = 0
    
    init(id: String, url: String, delegate: StreamPlayIsLiveDelegate?, completion: ((Result<StreamPlayIsLiveModel, StreamPlayIsLiveErrorModel>) -> Void)?) {
        self.id = id
        self.url = url
        self.delegate = delegate
        self.completion = completion
    }
    
    func checkForPoll(){
        if (Date.init().timeIntervalSince1970 > nextPoll){
            nextPoll = Date.init().timeIntervalSince1970 + 30
            callIsLiveURL()
        }
    }
    
    func callIsLiveURL(){
        StreamAMGSDK.sendRequest(url) { (result: Result<StreamPlayIsLiveModel, StreamAMGError>) in
            switch result {
            case .success(let data):
                self.nextPoll = data.nextPoll()
                self.delegate?.isLiveResponseRecieved(model: StreamPlayIsLiveModel.init(isLive: data.isLive, pollingFrequency: data.pollingFrequency, liveStreamID: self.id))
                if let completion = self.completion{
                completion(.success(data))
                }
            case .failure(let error):
                let isLiveError = StreamPlayIsLiveErrorModel.init(id: self.id)
                isLiveError.messages = error.getAllMessages()
                isLiveError.errorCode = error.getErrorCode()
                self.delegate?.isLiveErrorRecieved(model: isLiveError)
                if let completion = self.completion{
                completion(.failure(isLiveError))
                }
            }
        }
    }
    
}
