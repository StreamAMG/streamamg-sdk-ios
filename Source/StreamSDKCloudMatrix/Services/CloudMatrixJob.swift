//
//  CloudMatrixJob.swift
//  StreamSDKCloudMatrix
//
//  Created by Mike Hall on 27/01/2021.
//

import Foundation
//import StreamAMGSDK //Required only for running tests

/**
 A batchable CloudMatrix 'job' which can be added to the Core 'StreamSDKBatchJob' component
 */
public class CloudMatrixJob: JobDelegate {
    let request: CloudMatrixRequest
    let completion: ((Result<CloudMatrixResponse, StreamAMGError>) -> Void)?
    private var response: CloudMatrixResponse? = nil
    private var error: StreamAMGError? = nil
    private var completed = false
    public var delegate: BatchDelegate?
    
    /**
     * @param request A valid CloudMatrixRequest model
     * @param callback (Optional) a function to be run after the job is complete, has the signature '((CloudMatrixResponse?, StreamAMGError?) -> Unit)'
     */
    public init(request: CloudMatrixRequest, completion: ((Result<CloudMatrixResponse, StreamAMGError>) -> Void)?){
    self.request = request
    self.completion = completion
    }
    
    /**
     Delegate function that fires this current job from the batch service
     * This should not be run manually
     */
    public func fireRequest() {
        StreamAMGSDK.sendRequest(request.createURL()){ (result: Result<CloudMatrixResponse, StreamAMGError>) in
            switch result {
            case .success(let data):
                self.response = data
                self.completed = true

            case .failure(let error):
                logErrorCM(data: error.getMessages())
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
