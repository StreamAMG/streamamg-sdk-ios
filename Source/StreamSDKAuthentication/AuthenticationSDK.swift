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
    
    // MARK: Public Property
    
    
    /// Singleton instance for auth kit
    public static let instance = AuthenticationSDK()
    
    public var lastLoginResponse: LoginResponse? = nil
    
    // MARK: Private Property
    
    var url: String? = nil
    
    var parameters: Dictionary<String, String> = [:]
    
    // MARK: Public methods
    
    /**
     * Initialisation of the authentication SDK - URL is mandatory
     * @param url The url of the Authentication API
     * @param params A string represetation of any extra url parameters to add in the format 'key1=value1&key2=value2'
     */
    public func initWithURL(_ url: String, params: String? = nil) {
        self.url = url
        parameters.removeAll()
        if let params = params, params.count > 0 {
            separateParameters(params: params)
        }
        addLanguage()
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
        guard let token = lastLoginResponse?.authenticationToken else {
            let error = StreamAMGError(message: "User is not logged in")
            completion?(.failure(error))
            return
        }
        self.logoutWithToken(token: token, completion: completion)
    }
    
    
    /**
     Logs out a user by sending a logout request with the provided token.

     - Parameters:
        - token: The authentication token for the user.
        - completion: A closure to be called upon completion of the logout operation. It takes a `Result` enum as an argument, which can contain either a `.success` with a `SAResult` or a `.failure` with a `StreamAMGError`.

     - Note: Make sure the `url` property is properly set before calling this method.

     This function sends a logout request to the authentication API and handles the response accordingly.
     */
    public func logoutWithToken(token: String, completion: ((Result<SAResult, StreamAMGError>) -> Void)?) {
        // Check if the API URL is set
        guard let apiURL = url else {
            let error = StreamAMGError(message: "Authentication API URL not set")
            completion?(.failure(error))
            return
        }
        
        // Send the logout request
        StreamAMGSDK.sendRequest(logoutURL(url: apiURL, token: token)) { (result: Result<LoginResponse, StreamAMGError>) in
            switch result {
            case .success(_):
                // Clear the last login response and remove stored data upon successful logout
                self.lastLoginResponse = nil
                self.removeStoredData()
                completion?(.success(.SALogoutOK))
            case .failure(let error):
                // Clear the last login response and report the error in case of failure
                self.lastLoginResponse = nil
                completion?(.failure(error))
            }
        }
    }

    
    
    /// In order to perform queries against the CloudPay API a user must first initialise a session. This can be done for SSO users by generating a SSO Session.
    /// - Parameters:
    ///   - token: The Third-Party SSO token
    ///   - completion: Return the respone.
    public func startSession(token:String, completion: ((StreamAMGError?) -> Void)?){
        guard let apiURL = url else {
            let error = StreamAMGError(message: "Authentication API URL not set")
            completion?(error)
            return
        }
        
        StreamAMGSDK.sendRequest(ssoStartSessionURL(url: apiURL, token: token)){ (result: Result<LoginResponse, StreamAMGError>) in
            switch result {
            case .success(_):
                completion?(nil)
                break
            case .failure(let error):
                self.lastLoginResponse = nil
                completion?(error)
            }
        }
    }
    
    /**
     * Update user details. There is no need for the JWT token if previously logged in with the StreamAMG SDK.
     * @param email User's  first name
     * @param lastName User's  last name
     * @param completion Completion block capturing UserSummaryResponse or StreamAMGError
     */
    public func updateUserSummaryWithUserToken(firstName: String, lastName: String, completion: ((Result<UserSummaryResponse, StreamAMGError>) -> Void)?){
        
        guard let token = lastLoginResponse?.authenticationToken else {
            let error = StreamAMGError(message: "User is not logged in")
            completion?(.failure(error))
            return
        }
        
        updateUserSummaryWithUserToken(token: token, firstName: firstName, lastName: lastName, completion: completion)
    }
    
    /// Update user details. JWT token is needed if previously logged in with custom SSO.
    /// - Parameters:
    ///   - token: User's JWT token
    ///   - firstName: User's  first name
    ///   - lastName: User's  last name
    ///   - completion: JWT token is needed if previously logged in with custom SSO.
    public func updateUserSummaryWithUserToken(token: String, firstName: String, lastName: String, completion: ((Result<UserSummaryResponse, StreamAMGError>) -> Void)?){
        guard let apiURL = url else {
            let error = StreamAMGError(message: "Authentication API URL not set")
            completion?(.failure(error))
            return
        }
        if (firstName.isEmpty){
            let error = StreamAMGError(message: "First name not valid")
            completion?(.failure(error))
            return
        }
        if (lastName.isEmpty){
            let error = StreamAMGError(message: "Last name not valid")
            completion?(.failure(error))
            return
        }
        
        
        let request = UserSummaryRequest.init(FirstName: firstName, LastName: lastName)
        do {
            let body = try JSONEncoder().encode(request)
            StreamAMGSDK.sendPatchRequest(updateUserSummary(url: apiURL, token: token), body: body){ (result: Result<UserSummaryResponse, StreamAMGError>) in
                switch result {
                case .success(let data):
                    completion?(.success(data))
                case .failure(let error):
                    self.lastLoginResponse = nil
                    completion?(.failure(error))
                }
            }
        } catch {
            print("Error creating data - \(error.localizedDescription)")
        }
    }
    
    
    /// Returns an account summary of the Authenticated User.
    /// - Parameters:
    ///   - token: The JWT Token used for Authorisation
    ///   - completion: Completion block capturing UserSummaryResponse or StreamAMGError
    public func getUserSummary(token: String, completion: ((Result<UserSummaryResponse, StreamAMGError>) -> Void)?){
        guard let apiURL = url else {
            let error = StreamAMGError(message: "Authentication API URL not set")
            completion?(.failure(error))
            return
        }
       
        StreamAMGSDK.sendRequest(getUserSummaryURL(url: apiURL, token: token)){ (result: Result<UserSummaryResponse, StreamAMGError>) in
            switch result {
            case .success(let data):
                completion?(.success(data))
            case .failure(let error):
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
        guard let token = lastLoginResponse?.authenticationToken else {
            let error = StreamAMGError(message: "User is not logged in")
            completion?(.failure(error))
            return
        }
        self.getKSWithToken(token: token, entryID: entryID, completion: completion)
    }
    
    /**
     Retrieves a Key Session (KS) for a specific entry using the provided token.

     - Parameters:
        - token: The authentication token for the user.
        - entryID: The ID of the entry for which the KS is requested.
        - completion: A closure to be called upon completion of the KS retrieval operation. It takes a `Result` enum as an argument, which can contain either a `.success` with a tuple of `SAKSResult` and the KS string or a `.failure` with a `StreamAMGError`.

     - Note: Ensure that the `url` property is properly set before calling this method.

     This function sends a request to retrieve a Key Session (KS) for a specific entry and handles the response accordingly.
     */
    public func getKSWithToken(token: String, entryID: String, completion: ((Result<(SAKSResult, String), StreamAMGError>) -> Void)?) {
        // Check if the API URL is set
        guard let apiURL = url else {
            let error = StreamAMGError(message: "Authentication API URL not set")
            completion?(.failure(error))
            return
        }
        
        // Send the KS retrieval request
        StreamAMGSDK.sendRequest(ksURL(url: apiURL, entryID: entryID, token: token)) { (result: Result<LoginResponse, StreamAMGError>) in
            switch result {
            case .success(let data):
                if let status = SAKSResult(rawValue: data.status ?? -2) {
                    switch status {
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
    
    /**
     Performs a presence check for a user with the given token.

     - Parameters:
        - token: The user's authentication token.
        - completion: A closure to be called when the presence check is complete, containing the result.

     - Note: The presence check is used to determine the user's presence and retrieve user summary information.

     - Returns: A result containing either the user summary response on success or an error on failure.
     */
    public func validateActiveSession(token: String, completion: ((Result<LoginResponse, StreamAMGError>) -> Void)?) {
        // Ensure that the API URL is set.
        guard let apiURL = url else {
            let error = StreamAMGError(message: "Authentication API URL not set")
            completion?(.failure(error))
            return
        }

        // Send a request to perform the presence check.
        StreamAMGSDK.sendRequest(validateActiveSessionCheckURL(url: apiURL, token: token)) { (result: Result<LoginResponse, StreamAMGError>) in
            // Handle the result of the presence check.
            switch result {
            case .success(let data):
                // Call the completion handler with the user summary response on success.
                completion?(.success(data))
            case .failure(let error):
                // Call the completion handler with an error on failure.
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
    
    // MARK: Private methods
    
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
        return "\(url)/api/v1/session/start/\(addParameters())"
    }
    
    func logoutURL(url: String, token: String) -> String{
        return "\(url)/api/v1/session/terminate/?apisessionid=\(token)\(addParameters(includeQuerySign: false))"
    }
    
    func ksURL(url: String, entryID: String, token: String) -> String{
        return "\(url)/api/v1/session/ksession/?apisessionid=\(token)&entryId=\(entryID)\(addParameters(includeQuerySign: false))"
    }
    
    func updateUserSummary(url: String, token: String) -> String{
        return "\(url)/api/v1/account?apijwttoken=\(token)\(addParameters(includeQuerySign: false))"
    }
    
    func getUserSummaryURL(url: String, token: String) -> String{
        return "\(url)/api/v1/account?apijwttoken=\(token)\(addParameters(includeQuerySign: false))"
    }
    
    func ssoStartSessionURL(url: String, token: String) -> String{
        return "\(url)/sso/start?token=\(token)\(addParameters(includeQuerySign: false))"
    }
    
    func validateActiveSessionCheckURL(url: String, token: String) -> String{
        return "\(url)/api/v1/session/prescence?apijwttoken=\(token)\(addParameters(includeQuerySign: false))"
    }
}
