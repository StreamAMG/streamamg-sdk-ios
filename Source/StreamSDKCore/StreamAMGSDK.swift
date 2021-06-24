//
//  StreamAMGSDK.swift
//  StreamSDK-Core
//
//  Created by Mike Hall on 20/01/2021.
//

import Foundation
/**
  The main Core module object
 */
public class StreamAMGSDK {
    static var environment: StreamAPIEnvironment = .PRODUCTION
    
    /**
      Core component 'initialisation' - Sets the environment for the SDK
     * @param env PRODUCTION or STAGING - defaults to PRODUCTION
     */
    public static func initialise(env: StreamAPIEnvironment){
        environment = env
    }
    
    /**
     * Returns the 'environment' of the SDK, either .DEVELOPMENT (if set) or .PRODUCTION (default or guaranteed for production builds)
     */
    static func sdkEnvironment() -> StreamAPIEnvironment{
        #if DEBUG
            return environment
        #endif
        return .PRODUCTION
    }
    
    /**
      Disables all logging or, if requested, individual logging components
     * @param components A comma separated list of components to be disabled
     */
    public static func disableLogging(components: StreamSDKLogType...){
        if (components.count == 0){
            StreamSDKLogger.instance.turnLoggingOff()
        } else {
            StreamSDKLogger.instance.setLoggingForComponents(shouldLog: false, components: components)
        }
    }
    
    /**
      Enables all logging or, if requested, individual logging components
     * @param components A comma separated list of components to be enabled
     */
    public static func enableLogging(components: StreamSDKLogType...){
        if sdkEnvironment() != .PRODUCTION {
        if (components.count == 0){
            StreamSDKLogger.instance.turnLoggingOn()
        } else {
            StreamSDKLogger.instance.setLoggingForComponents(shouldLog: true, components: components)
        }
        }
    }

}
