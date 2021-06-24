//
//  StreamSDKBatchJob.swift
//  StreamSDKCore
//
//  Created by Mike Hall on 25/01/2021.
//

public protocol BatchDelegate {
    func updateTally()
}

public protocol JobDelegate {
    var delegate: BatchDelegate? { get set }
    
    func fireRequest()
    func runCompletion()
    func reset()
    func isComplete() -> Bool
}

public protocol BatchCompletionDelegate {
    func batchJobsCompleted()
}

import Foundation
/**
 Core component that services a batch of SDK network requests and fires their callbacks once all the jobs are complete
 * Supports any job that conforms to JobInterface (CloudMatrixJob and StreamPlayJob both conform)
 */
public class StreamSDKBatchJob: BatchDelegate {
    public var jobs: [JobDelegate] = []
    internal var hasCompleted = false
    var hasFired = false
    var tally = 0
    var delegate: BatchCompletionDelegate? = nil
    var removeJobsOnCompletion = false
    
    public init(delegate: BatchCompletionDelegate? = nil) {
        self.delegate = delegate
    }
    
    /**
     Add a job to the current batch
     */
    public func add(request: JobDelegate){
        var newJob = request
        newJob.delegate = self
        if (!hasFired){
            jobs.append(newJob)
        } else {
            logErrorCore(data: "Cannot add a job whilst batch is running")
        }
    }
    
    /**
     Start the batch jobs running - the jobs will run concurrently
     */
    public func fireBatch(removeOnCompletion: Bool = false){
        removeJobsOnCompletion = removeOnCompletion
        if (!hasFired){
            if (jobs.count == 0){
                logCore(data: "There are no jobs to process")
            } else {
                hasFired = true
                hasCompleted = false
                tally = 0
                jobs.forEach { job in
                    job.reset()
                    job.fireRequest()
                }
                checkCompletion()
            }
        } else {
            logErrorCore(data: "Cannot re-fire while the batch is running")
        }
    }
    
    private func checkCompletion() {
        if (hasCompleted){
            return
        }
        var allComplete = true
        jobs.forEach { job in
            if (!job.isComplete()){
                allComplete = false
            }
        }
        if (allComplete){
            if (!hasCompleted){
                completeJobs()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.checkCompletion()
            }
        }
    }
    
    /**
     Delegate function that keeps tabs on the number of jobs that have completed
     * This should not be run manually
     */
    public func updateTally() {
        tally += 1
        if (tally == jobs.count){
            if (!hasCompleted) {
                completeJobs()
            }
        }
    }
    
    public func removeJobs(){
        hasCompleted = false
        hasFired = false
        tally = 0
        jobs.removeAll()
    }
    
    public func removeJobsIfNotRunning(){
        if (!hasFired || hasCompleted){
            removeJobs()
        }
    }
    
    private func completeJobs() {
        hasCompleted = true
        hasFired = false
        jobs.forEach { job in
            job.runCompletion()
        }
        delegate?.batchJobsCompleted()
        if (removeJobsOnCompletion){
            removeJobs()
        }
    }
}
