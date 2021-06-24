//
//  StreamPlayLogging.swift
//  StreamSDKStreamPlay
//
//  Created by Mike Hall on 02/02/2021.
//

import Foundation
//import StreamAMGSDK //Required only for running tests

func logSP(data: String) {
    StreamSDKLogger.instance.log(entry: data, tag: "STREAMSDK-STREAMPLAY")
}

func logNetworkSP(data: String) {
    StreamSDKLogger.instance.logNetwork(entry: data, tag: "STREAMSDK-STREAMPLAY")
}

func logListSP(data: String) {
    StreamSDKLogger.instance.logList(entry: data, tag: "STREAMSDK-STREAMPLAY")
}

func logBoolSP(data: Bool, description: String) {
    StreamSDKLogger.instance.logBool(condition: data, description: description, tag: "STREAMSDK-STREAMPLAY")
}

func logErrorSP(data: String?) {
    StreamSDKLogger.instance.logError(entry: data, tag: "STREAMSDK-STREAMPLAY")
}
