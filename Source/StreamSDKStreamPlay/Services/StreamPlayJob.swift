//
//  StreamPlayJob.swift
//  StreamSDKStreamPlay
//
//  Created by Mike Hall on 27/01/2021.
//

import Foundation
//import StreamAMGSDK //Required only for running tests

/**
 A batchable StreamPlay 'job' which can be added to the Core 'StreamSDKBatchJob' component
 */
public class StreamPlayJob: JobDelegate {
    let request: StreamPlayRequest
    let completion: ((Result<StreamPlayResponse, StreamAMGError>) -> Void)?
    private var response: StreamPlayResponse? = nil
    private var error: StreamAMGError? = nil
    private var completed = false
    public var delegate: BatchDelegate?
    /**
     * @param request A valid StreamPlayRequest model
     * @param callback (Optional) a function to be run after the job is complete, has the signature '((StreamPlayResponse?, StreamAMGError?) -> Unit)'
     */
    public init(request: StreamPlayRequest, completion: ((Result<StreamPlayResponse, StreamAMGError>) -> Void)?){
    self.request = request
    self.completion = completion
    }
    /**
     Delegate function that fires this current job from the batch service
     * This should not be run manually
     */
    public func fireRequest() {
        StreamAMGSDK.sendRequest(request.createURL()){ (result: Result<StreamPlayResponse, StreamAMGError>) in
            switch result {
            case .success(let data):
                self.response = data
                self.completed = true

            case .failure(let error):
                logErrorSP(data: error.getMessages())
                self.error = error
                self.completed = true
            }
        }
    }
    /**
     Delegate function that fires on completion of this job
     * This should not be run manually
     */
    public func runCompletion() {
        if let error = error {
            completion?(.failure(error))
            return
        }
        if let response = response {
            completion?(.success(response))
        }
    }
    /**
     Delegate function that resets this job to re-run
     * This should not be run manually
     */
    public func reset() {
        completed = false
    }
    /**
     Checks if this job is completed
     * Delegate function, but may be run manually if required
     */
    public func isComplete() -> Bool {
        return completed
    }
    
    
}
