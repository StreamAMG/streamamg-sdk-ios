//
//  AuthenticationSDK.swift
//  StreamAMGSDK
//
//  Created by Mike Hall on 19/02/2021.
//

import Foundation

/**
 Provides access to StreamAMG Authentication API
 */

public class AuthenticationSDK {
    
    /**
     * Singleton instance for auth kit
     */
    public static let instance = AuthenticationSDK()
    
    var url: String? = nil
    
    var parameters: Dictionary<String, String> = [:]
    
    public var lastLoginResponse: LoginResponse? = nil
    
    /**
     * Initialisation of the authentication SDK - URL is mandatory
     * @param url The url of the Authentication API
     * @param params A string represetation of any extra url parameters to add in the format 'key1=value1&key2=value2'
     */
    public func initWithURL(_ url: String, params: String? = nil) {
        self.url = url
        if let params = params, params.count > 0 {
            separateParameters(params: params)
        }
        addLanguage()
    }
    
    func separateParameters(params: String){
        var passedParams = params
        if passedParams.starts(with: "?"){
            passedParams.remove(at: passedParams.startIndex)
        }
        let allParams = passedParams.split(separator: "&")
        allParams.forEach{param in
            let thisParam = param.split(separator: "=")
            if thisParam.count == 2 {
                parameters[String(thisParam[0])] = String(thisParam[1])
            }
        }
    }
    
    func addLanguage(){
        if let _ = parameters["lang"] {
            return
        }
        parameters["lang"] = NSLocale.preferredLanguages.first
    }

    /**
     * Returns a Boolean value indicating the user's logged in status
     */
    public func isLoggedIn() -> Bool {
        return lastLoginResponse?.currentCustomerSession != nil
    }
    
    /**
     * If a user's login / password has been verified and stored in the Keychain, this function will automatically log them back in when called
     */
    public func loginSilent(completion: ((Result<StreamAMGUserModel, StreamAMGError>) -> Void)?){
        if let loginDetails = securelyRetrieveEmailAndPass() {
            login(email: loginDetails.email, password: loginDetails.password, completion: completion)
        } else {
            completion?(.failure(StreamAMGError(message: "No stored user found")))
        }
    }
    
    /**
     * Main login function - authenticates the user's email / password combination and returns a UserModel or StreamAMGError
     * @param email User's valid email address
     * @param password User's valid password
     * @param completion Completion block capturing StreamAMGUserModel or StreamAMGError
     */
    public func login(email: String, password: String, completion: ((Result<StreamAMGUserModel, StreamAMGError>) -> Void)?){
        guard let apiURL = url else {
            let error = StreamAMGError(message: "Authentication API URL not set")
            completion?(.failure(error))
            return
        }
        if (email.isEmpty){
            let error = StreamAMGError(message: "Email address not valid")
            completion?(.failure(error))
            return
        }
        if (password.isEmpty){
            let error = StreamAMGError(message: "Password not valid")
            completion?(.failure(error))
            return
        }
        let request = LoginRequest.init(emailAddress: email, password: password)
        do {
        let body = try JSONEncoder().encode(request)
            StreamAMGSDK.sendPostRequest(loginURL(url: apiURL), body: body){ (result: Result<LoginResponse, StreamAMGError>) in
                switch result {
                case .success(let data):
                    if let userModel = data.currentCustomerSession {
                    self.lastLoginResponse = data
                    self.securelyStoreEmailAndPass(email: email, password: password)
                    completion?(.success(userModel))
                    } else {
                        let error = StreamAMGError(message: "No user session returned")
                        completion?(.failure(error))
                    }
                case .failure(let error):
                    self.lastLoginResponse = nil
                    completion?(.failure(error))
                }
            }
        } catch {
            print("Error creating data - \(error.localizedDescription)")
        }
    }
    
    /**
     * Main logout function - sends logout to the API, removes the LoginModel (and UserModel) from the Authentication SDK and removes the securely stored email / password combo from KeyChain
     * @param completion Completion block capturing StreamAMGUserModel or StreamAMGError
     */
    public func logout(completion: ((Result<SAResult, StreamAMGError>) -> Void)?){
        guard let apiURL = url else {
            let error = StreamAMGError(message: "Authentication API URL not set")
            completion?(.failure(error))
            return
        }
        guard let token = lastLoginResponse?.authenticationToken else {
            let error = StreamAMGError(message: "User is not logged in")
            completion?(.failure(error))
            return
        }
        StreamAMGSDK.sendRequest(logoutURL(url: apiURL, token: token)){ (result: Result<LoginResponse, StreamAMGError>) in
            switch result {
            case .success(_):
                self.lastLoginResponse = nil
                self.removeStoredData()
                completion?(.success(.SALogoutOK))
            case .failure(let error):
                self.lastLoginResponse = nil
                completion?(.failure(error))
            }
        }
    }
    
    /**
     * Request Key Session token for a particular Entry ID
     * @param entryID Valid entry ID for an item of StreamAMG media
     * @param completion Completion block capturing StreamAMGUserModel or StreamAMGError
     */
    public func getKS(entryID: String, completion: ((Result<(SAKSResult, String), StreamAMGError>) -> Void)?){
        guard let apiURL = url else {
            let error = StreamAMGError(message: "Authentication API URL not set")
            completion?(.failure(error))
            return
        }
        guard let token = lastLoginResponse?.authenticationToken else {
            let error = StreamAMGError(message: "User is not logged in")
            completion?(.failure(error))
            return
        }
        StreamAMGSDK.sendRequest(ksURL(url: apiURL, entryID: entryID, token: token)){ (result: Result<LoginResponse, StreamAMGError>) in
            switch result {
            case .success(let data):
                if let status = SAKSResult(rawValue: data.status ?? -2){
                switch status{
                case .Granted:
                if let session = data.kSession {
                    completion?(.success((.Granted, session)))
                } else {
                    let error = StreamAMGError(message: "Unknown error occurred - \(data.status ?? -4)")
                    completion?(.failure(error))
                }
                default:
                    let error = StreamAMGError(message: status.meaning())
                    if let furtherError = data.errorMessage {
                        error.addMessage(message: furtherError)
                    }
                    completion?(.failure(error))
                }
                } else {
                    let error = StreamAMGError(message: "Unknown error occurred - \(data.status ?? -3)")
                    if let furtherError = data.errorMessage {
                        error.addMessage(message: furtherError)
                    }
                    completion?(.failure(error))
                }
            case .failure(let error):
                self.lastLoginResponse = nil
                completion?(.failure(error))
            }
        }
    }
    
    func securelyStoreEmailAndPass(email: String, password: String){
        _ = KeyChain.store(key: "authEmail", data: email)
        _ = KeyChain.store(key: "authPassword", data: password)
    }
    
    /**
     * Returns a tuple containing the securely stored email / password combo
     */
    public func securelyRetrieveEmailAndPass() -> (email: String, password: String)? {
        if let email = KeyChain.retrieveString(key: "authEmail"), let password = KeyChain.retrieveString(key: "authPassword"){
            return (email, password)
        }
        return nil
    }
    
    func removeStoredData(){
        let emailSuccess = KeyChain.remove(key: "authEmail")
        let passwordSuccess = KeyChain.remove(key: "authPassword")
        print("Deleting auth:\nEmail - \(emailSuccess)\nPassword - \(passwordSuccess)")
    }
    
    func addParameters(includeQuerySign: Bool = true) -> String {
        var parameterString = ""
        if !parameters.isEmpty {
            if  includeQuerySign {
            parameterString = "?"
            } else {
                parameterString = "&"
            }
            parameters.forEach{ parameter in
                if parameterString.count > 1 {
                    parameterString = "\(parameterString)&"
                }
                parameterString = "\(parameterString)\(parameter.key)=\(parameter.value)"
            }
        }
        return parameterString
    }
    
    func loginURL(url: String) -> String{
        return "\(url)api/v1/session/start/\(addParameters())"
    }
    
    func logoutURL(url: String, token: String) -> String{
        return "\(url)api/v1/session/terminate/?apisessionid=\(token)\(addParameters(includeQuerySign: false))"
    }
    
    func ksURL(url: String, entryID: String, token: String) -> String{
        return "\(url)api/v1/session/ksession/?apisessionid=\(token)&entryId=\(entryID)\(addParameters(includeQuerySign: false))"
    }
    
}
