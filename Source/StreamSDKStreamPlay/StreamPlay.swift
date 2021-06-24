//
//  StreamPlay.swift
//  StreamAMGStreamPlay
//
//  Created by Mike Hall on 25/01/2021.
//

import Foundation
/**
 This class forms the base StreamPlay object.
 */
public class StreamPlay {
    
    var currentRequest: StreamPlayRequest? = nil
    var currentResponse: StreamPlayResponse? = nil
    public init(){
        
    }
    
    public var currentCompletion: ((Result<StreamPlayResponse, StreamAMGError>) -> Void)?
    
    /**
      Call the Core networking module and pass a request to the StreamPlay API
     * @param request - The request model to send to StreamPlay
     * @param completion - code to be executed on receipt of a valid response or error
     */
    public func callAPI(request: StreamPlayRequest, completion: ((Result<StreamPlayResponse, StreamAMGError>) -> Void)?) {
        currentCompletion = completion
        currentRequest = request
        StreamAMGSDK.sendRequest(request.createURL(), component: .STREAMPLAY){ (result: Result<StreamPlayResponse, StreamAMGError>) in
            switch result {
            case .success(let data):
                self.currentResponse = data
                self.currentCompletion?(.success(data))
                
            case .failure(let error):
                self.currentCompletion?(.failure(error))
            }
        }
    }
    
    /**
      Call the API requesting the previous page (if any)
     */
    public func loadPreviousPage(){
        if let response = currentResponse, let request = currentRequest {
            let previousPage = response.previousPage()
            if (previousPage < request.currentOffset){
                request.currentOffset = previousPage
                callAPI(request: request, completion: currentCompletion)
            } else {
                logErrorSP(data: "No further data available")
            }
            return
        }
        logErrorSP(data: "No response available")
    }
    
    /**
     Call the API requesting the next page (if any)
    */
    public func loadNextPage(){
        if let response = currentResponse, let request = currentRequest {
            let nextPage = response.nextPage()
            if (nextPage > request.currentOffset){
                request.currentOffset = nextPage
                request.currentOffset = nextPage
                callAPI(request: request, completion: currentCompletion)
            } else {
                logErrorSP(data: "No further data available")
            }
            return
        }
        logErrorSP(data: "No response available")
    }
    
    
    
}
