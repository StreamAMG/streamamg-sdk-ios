//
//  CloudMatrixLogging.swift
//  StreamSDKCloudMatrix
//
//  Created by Mike Hall on 02/02/2021.
//

import Foundation
//import StreamAMGSDK //Required only for running tests

func logCM(data: String) {
    StreamSDKLogger.instance.log(entry: data, tag: "STREAMSDK-CLOUDMATRIX")
}

func logNetworkCM(data: String) {
    StreamSDKLogger.instance.logNetwork(entry: data, tag: "STREAMSDK-CLOUDMATRIX")
}

func logListCM(data: String) {
    StreamSDKLogger.instance.logList(entry: data, tag: "STREAMSDK-CLOUDMATRIX")
}

func logBoolCM(data: Bool, description: String) {
    StreamSDKLogger.instance.logBool(condition: data, description: description, tag: "STREAMSDK-CLOUDMATRIX")
}

func logErrorCM(data: String?) {
    StreamSDKLogger.instance.logError(entry: data, tag: "STREAMSDK-CLOUDMATRIX")
}
