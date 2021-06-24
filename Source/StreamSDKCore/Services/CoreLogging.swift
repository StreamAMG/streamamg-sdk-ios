//
//  CoreLogging.swift
//  StreamSDKCore
//
//  Created by Mike Hall on 02/02/2021.
//

import Foundation

func logCore(data: String) {
    StreamSDKLogger.instance.log(entry: data, tag: "STREAMSDK-CORE")
}

func logNetworkCore(data: String) {
    StreamSDKLogger.instance.logNetwork(entry: data, tag: "STREAMSDK-CORE")
}

func logListCore(data: String) {
    StreamSDKLogger.instance.logList(entry: data, tag: "STREAMSDK-CORE")
}

func logBoolCore(data: Bool, description: String) {
    StreamSDKLogger.instance.logBool(condition: data, description: description, tag: "STREAMSDK-CORE")
}

func logErrorCore(data: String?) {
    StreamSDKLogger.instance.logError(entry: data, tag: "STREAMSDK-CORE")
}
