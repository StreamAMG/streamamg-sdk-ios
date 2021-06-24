//
//  CloudMatrixRequest.swift
//  StreamSDK-CloudMatrix
//
//  Created by Mike Hall on 21/01/2021.
//

import Foundation
/**
 Model that holds the payload of a request to the CloudMatrix API
 */
public class CloudMatrixRequest {
    
    var apiFunction: CloudMatrixFunction = CloudMatrixFunction.FEED
    var event: String? = nil
    var params: [SearchParameter] = []
    var url: String? = nil
    var paginateBy: Int = 0
    var currentPage: Int = 0
    
    private var cmSetup: CloudMatrixSetupModel? = nil
    
    /**
     * It is preferred that a builder class is used to ensure all relevant information is included
     * @param apiFunction 'CloudMatrixFunction' enum that determines what type of call is made - defaults to 'FEED'
     * @param event The ID of the event being queried
     * @param params A list of 'SearchParameter' objects containing valid queries
     * @param url A URL that should be directly queried
     * @param paginateBy A requested number of items per page to be returned - default is 200
     */
    public init(apiFunction: CloudMatrixFunction = CloudMatrixFunction.FEED, event: String? = nil, params: [SearchParameter] = [], url: String? = nil, paginateBy: Int = 0){
        self.apiFunction = apiFunction
        self.event = event
        self.params = params
        self.url = url
        self.paginateBy = paginateBy
    }
    
    internal func createURL() -> String {
        if let guaranteedURL = url, params.isEmpty {
            let query = paginatedStaticURL(guaranteedURL: guaranteedURL)
            logNetworkCM(data: "Query = $query")
            return query
        }
        if let cmSetupData = cmSetup, cmSetupData.userID.count > 0 {
                let query = "\(baseURL())/\(cmSetupData.version)/\(cmSetupData.userID)/\(cmSetupData.key)/\(cmSetupData.language)/\(apiFunction.method())/\(specificEvent())\(parmeters())"
                logNetworkCM(data: "Query = $query")
                return query
        }
        if let guaranteedURL = url {
            var query = ""
            if guaranteedURL.contains("?"){
                query = amendedSearchURL(guaranteedURL: guaranteedURL)
            } else if guaranteedURL.contains("search"){
                query = "\(guaranteedURL)\(parmeters())"
            } else {
            query = "\(guaranteedURL)/\(apiFunction.method())/\(specificEvent())\(parmeters())"
            }
            logNetworkCM(data: "Query = \(query)")
            return query
        }
        logErrorCM(data: "StreamSDK CloudMatrix is not initialised.")
        return ""
    }
    
    func parmeters(append: Bool = false) -> String {
        switch apiFunction {
        case .SEARCH:
            return searchParameters(append: append)
        default:
            return ""
        }
    }
    
    func paginatedStaticURL(guaranteedURL: String) -> String{
        var returnURL = guaranteedURL
        if (!returnURL.contains("?")){
            if (returnURL.hasSuffix("sections")){
                returnURL += "/search"
            } else if (returnURL.hasSuffix("sections/")){
                returnURL += "search"
            }
            returnURL += "?"
        } else {
            returnURL += "&"
        }
        return returnURL + pagination()
    }
    
    func amendedSearchURL(guaranteedURL: String) -> String{
        var returnURL = guaranteedURL
        var parameters = ""
        params.forEach{parameter in
            if !parameter.query.isEmpty || parameter.searchType == .EXISTS {
                parameters = "\(parameters)%20AND%20"
            parameters = "\(parameters)\(parameterString(parameter: parameter))"
        }
        if returnURL.contains(")))"){
            if let initialindex = returnURL.index(of: "))")  {
                 let index = returnURL.index(after: initialindex)
                    let firstPart = returnURL.prefix(upTo: index)
                let secondPart = returnURL.suffix(from: index)
                if !firstPart.isEmpty && !secondPart.isEmpty {
                    returnURL = "\(firstPart)\(parameters)\(secondPart)"
                }
            }
        } else if returnURL.contains("))"){
            if let index = returnURL.index(of: "))")  {
                    let firstPart = returnURL.prefix(upTo: index)
                let secondPart = returnURL.suffix(from: index)
                if !firstPart.isEmpty && !secondPart.isEmpty {
                    returnURL = "\(firstPart)\(parameters)\(secondPart)"
                }
            }
        }
        }
        //let param = "\(append ? "&" : "?query=")(\(parameters))&\(pagination())"
        returnURL = "\(returnURL)&\(pagination())"
        logCM(data: returnURL)
        return returnURL
    }
    
    func pagination() -> String {
        
        var pagination = "pageIndex=\(currentPage)"
        if (paginateBy > 0){
            pagination += "&pageSize=\(paginateBy)"
        }
        return pagination
    }
    
    func searchParameters(append: Bool = false) -> String {
        if params.isEmpty {
            return "?\(pagination())"
        }
        var parameters = ""
        params.forEach{parameter in
            if !parameter.query.isEmpty || parameter.searchType == .EXISTS {
            if (parameters.count > 0) {
                parameters = "\(parameters)%20AND%20"
            }
            parameters = "\(parameters)\(parameterString(parameter: parameter))"
            }
        }
        var param = ""
        if (parameters.isEmpty){
            param = "?\(pagination())"
        } else {
         param = "\(append ? "&" : "?query=")(\(parameters))&\(pagination())"
        }
        logCM(data: param)
        return param
    }
    
    func parameterString(parameter: SearchParameter)-> String {
        switch parameter.searchType {
        case.EXISTS:
            return "_exists_:\(parameter.target)"
        default:
            return "\(parameter.target):\(parameter.searchType.queryOperator())\(parameter.query)"
        }
        
    }
    /**
     Adds a parameter to the current params list
     * @param parameter A 'SearchParameter' object containing a valid query
     */
    public func addSearch(parameter: SearchParameter) {
        params.append(parameter)
    }
    
    func specificEvent() -> String {
        
        switch apiFunction {
        case .FEED:
            if let event = event{
                return "\(event)/sections/"
            }
        default:
            return""
        }
        return""
    }
    
    func baseURL() -> String {
        if let cmSetup = cmSetup {
            switch StreamAMGSDK.sdkEnvironment() {
            case .PRODUCTION:
                return cmSetup.url
            default:
                return cmSetup.debugURL
            }
        }
        return ""
    }
    /**
    Sets the current CloudMatrix setup model for all API calls
     */
    public func updateWith(setupModel: CloudMatrixSetupModel) {
        cmSetup = setupModel
    }
    
    /**
     Builder class for creating 'FEED' queries
     * It is preferred that a builder class is used to ensure all relevant information is included
     */
    public class FeedBuilder {
        var eventObject: String? = nil
        var paramsObject: [SearchParameter] = []
        var urlObject: String? = nil
        var setup: CloudMatrixSetupModel? = nil
        var paginateObject: Int = 0
        
        public init(){
            
        }
        
        /**
         Adds an event ID to the query - should not be used with 'url'
         */
        public func event(_ eventID: String) -> FeedBuilder {
            self.eventObject = eventID
            return self
        }
        /**
         Adds a fully formed URL to the query - should not be used with 'event'
         */
        public func url(_ url: String) -> FeedBuilder {
            self.urlObject = url
            return self
        }
        /**
         * A requested number of items per page to be returned - default is 200
         */
        public func paginateBy(_ paginateBy: Int) -> FeedBuilder {
            self.paginateObject = paginateBy
            return self
        }
        
        /**
         * A setup Model providing CloudMatrix credentials for this call
         */
        public func cmTarget(_ target: CloudMatrixSetupModel) -> FeedBuilder {
            self.setup = target
            return self
        }
        
        /**
         * Returns a valid CloudMatrixRequest
         */
        public func build() -> CloudMatrixRequest {
            let request = CloudMatrixRequest(apiFunction: .FEED, event: eventObject, url: urlObject, paginateBy: paginateObject)
            request.cmSetup = setup
            return request
        }
        
    }
    
    /**
    Builder class for creating 'SEARCH' queries
     * It is preferred that a builder class is used to ensure all relevant information is included
     */
    public class SearchBuilder {
        var paramsObject: [SearchParameter] = []
        var paginateObject: Int = 0
        var setup: CloudMatrixSetupModel? = nil
        var workableURL: String? = nil
        
        public init(){
            
        }
        
        
        public func url(_ url: String) -> SearchBuilder {
            // Strip 'feed' info from URL
            if url.contains("/feed/") {
                if let index = url.index(of: "/feed/") {
                    let firstPart = url.prefix(upTo: index)
                    workableURL = String(firstPart)
                    return self
                }
            }
            // Strip 'search' info from URL
            if url.contains("/search") {
//                if let index = url.index(of: "/search/") {
//                    let firstPart = url.prefix(upTo: index)
//                    workableURL = String(firstPart)
//                    return self
//                }
                workableURL = url
            }
            return self
        }
        
        
        public func parameters(_ parameters: [SearchParameter]) -> SearchBuilder {
            self.paramsObject.append(contentsOf: parameters)
            return self
        }
        
        public func parameter(_ parameter: SearchParameter) -> SearchBuilder {
            self.paramsObject.append(parameter)
            return self
        }
        
        /**
         Adds an 'equality' check to the query that returns only items in which this field contains a complete word or string that matches the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isEqualTo(target: CloudMatrixQueryType, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: query))
            return self
        }
        
        /**
          Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) greater than the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThan(target: CloudMatrixQueryType, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHAN, target: target.query(), query: query))
            return self
        }
        
        /**
          Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) greater than or equal to the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThanOrEqualTo(target: CloudMatrixQueryType, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHANOREQUALTO, target: target.query(), query: query))
            return self
        }
        
        /**
          Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) less than the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThan(target: CloudMatrixQueryType, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHAN, target: target.query(), query: query))
            return self
        }
        
        /**
          Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) less than or equal to the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThanOrEqualTo(target: CloudMatrixQueryType, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHANOREQUALTO, target: target.query(), query: query))
            return self
        }
        
        /**
         Adds an 'equality' check to the query that returns only items in which this field contains a NSNumber equal to the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isEqualTo(target: CloudMatrixQueryType, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value less than the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThan(target: CloudMatrixQueryType, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHAN, target: target.query(), query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value greater than or equal to the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThanOrEqualTo(target: CloudMatrixQueryType, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHANOREQUALTO, target: target.query(), query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value less than the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThan(target: CloudMatrixQueryType, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHAN, target: target.query(), query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value less than or equal to the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThanOrEqualTo(target: CloudMatrixQueryType, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHANOREQUALTO, target: target.query(), query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'fuzzy' check to the query that returns only items in which this field where any word or continual string of the value contains the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLike(target: CloudMatrixQueryType, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .FUZZY, target: target.query(), query: "*$query*"))
            return self
        }
        
        /**
         Adds a 'fuzzy' check to the query that returns only items in which this field where any word or continual string of the value starts with the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func startsWith(target: CloudMatrixQueryType, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "$query*"))
            return self
        }
        
        /**
         Adds a 'fuzzy' check to the query that returns only items in which this field where any word or continual string of the value ends with the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func endsWith(target: CloudMatrixQueryType, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "*$query"))
            return self
        }
        
        /**
         Adds a boolean check to the query that returns only items in this field which are 'true'
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         */
        public func isTrue(target: CloudMatrixQueryType) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "true"))
            return self
        }
        
        /**
         Adds a boolean check to the query that returns only items in this field which are 'false'
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         */
        public func isFalse(target: CloudMatrixQueryType) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "false"))
            return self
        }
        
        /**
         Adds a check to the query that returns only items in which this field exists
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         */
        public func exists(target: CloudMatrixQueryType) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EXISTS, target: target.query(), query: ""))
            return self
        }
        
        /**
         Adds a 'containing' check to the query that returns only items where this array field contains the query
         * @param target A 'CloudMatrixQueryType' enum indicating the field to query
         * @param query The actual data to query
         */
        public func contains(target: CloudMatrixQueryType, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: query))
            return self
        }
        
        
        /**
         Adds an 'equality' check to the query that returns only items in which this field contains a complete word or string that matches the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isEqualTo(target: String, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target, query: query))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) greater than the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThan(target: String, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHAN, target: target, query: query))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) greater than or equal to the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThanOrEqualTo(target: String, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHANOREQUALTO, target: target, query: query))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) less than the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThan(target: String, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHAN, target: target, query: query))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) less than or equal to the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThanOrEqualTo(target: String, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHANOREQUALTO, target: target, query: query))
            return self
        }
        
        /**
         Adds an 'equality' check to the query that returns only items in which this field contains a NSNumber equal to the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isEqualTo(target: String, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target, query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value less than the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThan(target: String, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHAN, target: target, query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value greater than or equal to the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThanOrEqualTo(target: String, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHANOREQUALTO, target: target, query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value less than the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThan(target: String, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHAN, target: target, query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value less than or equal to the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThanOrEqualTo(target: String, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHANOREQUALTO, target: target, query: "\(query)"))
            return self
        }
        
        /**
         Adds a 'fuzzy' check to the query that returns only items in which this field where any word or continual string of the value contains the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func isLike(target: String, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .FUZZY, target: target, query: "*$query*"))
            return self
        }
        
        /**
         Adds a 'fuzzy' check to the query that returns only items in which this field where any word or continual string of the value starts with the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func startsWith(target: String, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target, query: "$query*"))
            return self
        }
        
        /**
         Adds a 'fuzzy' check to the query that returns only items in which this field where any word or continual string of the value ends with the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func endsWith(target: String, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target, query: "*$query"))
            return self
        }
        
        /**
         Adds a boolean check to the query that returns only items in this field which are 'true'
         * @param target A String indicating the field to query
         */
        public func isTrue(target: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target, query: "true"))
            return self
        }
        
        /**
         Adds a boolean check to the query that returns only items in this field which are 'false'
         * @param target A String indicating the field to query
         */
        public func isFalse(target: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target, query: "false"))
            return self
        }
        
        /**
         Adds a check to the query that returns only items in which this field exists
         * @param target A String indicating the field to query
         */
        public func exists(target: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EXISTS, target: target, query: ""))
            return self
        }
        
        /**
         Adds a 'containing' check to the query that returns only items where this array field contains the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func contains(target: String, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target, query: query))
            return self
        }
        
        
        /**
         Adds a 'containing' check to the query that returns only items where this array field contains the query
         * @param target A String indicating the field to query
         * @param query The actual data to query
         */
        public func cmTarget(_ target: CloudMatrixSetupModel) -> SearchBuilder {
            self.setup = target
            return self
        }
        
        
        public func paginateBy(_ paginateBy: Int) -> SearchBuilder {
            self.paginateObject = paginateBy
            return self
        }
        
        public func build() -> CloudMatrixRequest {
            let request = CloudMatrixRequest(apiFunction: .SEARCH, params: paramsObject, paginateBy: paginateObject)
            request.cmSetup = setup
            request.url = workableURL
            return request
        }
        
    }
    
}

import Foundation

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
