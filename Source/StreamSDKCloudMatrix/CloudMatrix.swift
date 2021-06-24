//
//  CloudMatrix.swift
//  StreamSDK-CloudMatrix
//
//  Created by Mike Hall on 21/01/2021.
//

import Foundation
//import StreamAMGSDK //Required only for running tests

/**
 This class forms the base CloudMatrix object.
 */
public class CloudMatrix {
    
    public init(){
        
    }
    
    var currentRequest: CloudMatrixRequest? = nil
    var currentResponse: CloudMatrixResponse? = nil
    public var currentCompletion: ((Result<CloudMatrixResponse, StreamAMGError>) -> Void)?
    /**
     * Call the Core networking module and pass a request to the CloudMatrix API
     * @param request - The request model to send to CloudMatrix
     * @param completion - code to be executed on receipt of a valid response or error
     */
    public func callAPI(request: CloudMatrixRequest, completion: ((Result<CloudMatrixResponse, StreamAMGError>) -> Void)?) {
        currentCompletion = completion
        currentRequest = request
        StreamAMGSDK.sendRequest(request.createURL(), component: .CLOUDMATRIX){ (result: Result<CloudMatrixResponse, StreamAMGError>) in
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
     * Call the API requesting the previous page (if any)
     */
    public func loadPreviousPage(){
        if let response = currentResponse, let request = currentRequest {
            let previousPage = response.previousPage()
            if (previousPage < request.currentPage){
                request.currentPage = previousPage
                callAPI(request: request, completion: currentCompletion)
            } else {
                logErrorCM(data: "No further data available")
            }
            return
        }
        logErrorCM(data: "No response available")
    }
    
    /**
     * Call the API requesting the next page (if any)
     */
    public func loadNextPage(){
        if let response = currentResponse, let request = currentRequest {
            let nextPage = response.nextPage()
            if (nextPage > request.currentPage){
                request.currentPage = nextPage
                callAPI(request: request, completion: currentCompletion)
            } else {
                logErrorCM(data: "No further data available")
            }
            return
        }
        logErrorCM(data: "No response available")
    }
    
    
}
