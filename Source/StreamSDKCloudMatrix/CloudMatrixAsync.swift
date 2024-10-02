//
//  CloudMatrixAsync.swift
//  StreamAMG
//
//  Created by Zachariah Tom on 20/06/2024.
//

import Foundation

public class CloudMatrixAsync {
    
    private let sdk: StreamAMGSDKType
    
    public init(sdk: StreamAMGSDKType? = nil) {
        self.sdk = sdk ?? StreamAMGSDK()
    }
    
    /**
     * Call the Core networking module and pass a request to the CloudMatrix API
     * @param request - The request model to send to CloudMatrix
     */
    public func callAPI(request: CloudMatrixRequest) async throws -> CloudMatrixResponse {
        let result: Result<CloudMatrixResponse, StreamAMGError> = await sdk.sendRequestAsync(request.createURL(), component: .CLOUDMATRIX)
        return try result.get()
    }
}
