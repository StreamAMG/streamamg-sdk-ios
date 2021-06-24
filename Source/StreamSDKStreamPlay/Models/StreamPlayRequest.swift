//
//  StreamPlayRequest.swift
//  StreamAMGStreamPlay
//
//  Created by Mike Hall on 25/01/2021.
//

import Foundation
/**
  Model that holds the payload of a request to the StreamPlay API
 */
public class StreamPlayRequest {
    var sport: [StreamPlaySport] = []
    var fixtureID: String? = nil
    var partnerID: String? = nil
    var params: [SearchParameter] = []
    var url: String? = nil
    var paginateBy: Int = 0
    
    var currentOffset: Int = 0
    /**
     * It is preferred that a builder class is used to ensure all relevant information is included
     * @param sport Array list of 'StreamPlaySport' enums the partner has access to
     * @param fixtureID The ID of the fixture being queried
     * @param partnerID The ID of the partner accessing the API
     * @param params A list of 'SearchParameter' objects containing valid queries
     * @param url A URL that should be directly queried
     * @param paginateBy A requested number of items per page to be returned - default is 20
     */
    public init(sport: [StreamPlaySport] = [], fixtureID: String? = nil, partnerID: String? = nil, params: [SearchParameter] = [], url: String? = nil, paginateBy: Int = 0){
        self.sport = sport
        self.fixtureID = fixtureID
        self.partnerID = partnerID
        self.params = params
        self.url = url
        self.paginateBy = paginateBy
    }
    
    internal func createURL() -> String {
        if let guaranteedURL = url, params.isEmpty{
            let query = paginatedStaticURL(guaranteedURL: guaranteedURL)
            logNetworkSP(data: "Query = $query")
            return query
        }
        if let partID = partnerID {
            if let fixID = fixtureID {
                let query = paginatedStaticURL(guaranteedURL: "\(baseURL())fixtures\(getSingleSport())/p/\(partID)\(searchParameters())?q=(id:\(fixID)")
                logNetworkSP(data: "Query = $query")
                return query
            }
            let query = "\(baseURL())fixtures\(getSingleSport())/p/\(partID)\(searchParameters())"
            //   logNetworkSP("Query = $query")
            return query
            
        }
        if let guaranteedURL = url {
            var additionalParameters = searchParameters()
            if guaranteedURL.contains("?q=") {
                additionalParameters = additionalParameters.replacingOccurrences(of: "?q=", with: " AND ")
            }
                let query = paginatedStaticURL(guaranteedURL: "\(guaranteedURL)\(additionalParameters)")
                logNetworkSP(data: "Query = $query")
            return query
            
        }
        logErrorSP(data: "Criteria for constructing feed not met.")
        return ""
    }
    
    func getSingleSport() -> String {
        if sport.count >= 1{
            return "/\(sport[0].value())"
        }
        return ""
    }
    
    func paginatedStaticURL(guaranteedURL: String) -> String{
        var returnURL = guaranteedURL
        if (!returnURL.contains("?")){
            returnURL += "?"
        } else {
            returnURL += "&"
        }
        return returnURL + pagination()
    }
    
    func pagination() -> String {
        
        var pagination = "offset=\(currentOffset)"
        if (paginateBy > 0){
            pagination += "&limit=\(paginateBy)"
        }
        return pagination
    }
    
    func searchParameters() -> String {
        if params.isEmpty {
            return "?\(pagination())"
        }
        var parameters = ""
        var media = ""
        var extra = ""
        params.forEach {parameter in
            switch StreamPlayQueryType.init(rawValue: parameter.queryType) {
            case .PARAMETER:
                if (parameters.count > 0) {
                    parameters += "%20AND%20"
                }
                parameters += parameterString(parameter: parameter)
            case .MEDIA:
                if (media.count > 0) {
                    media += "%20AND%20"
                }
                media += parameterString(parameter: parameter)
            case .EXTRA:
                if (extra.count > 0) {
                    extra += "&"
                }
                extra += parameterString(parameter: parameter)
            case .none:
                break
            }
            
        }
        
        var param = "?"
        if (parameters.count > 0) {
            param += "q=(\(parameters))"
        }
        if (media.count > 0) {
            if (param.count>1){
                param += "&"
            }
            param += "q=(\(media))"
        }
        if (extra.count > 0) {
            if (param.count>1){
                param += "&"
            }
            param += extra
        }
        //  logSP(param)
        return param
    }
    
    func parameterString(parameter: SearchParameter)-> String {
        if parameter.queryList.count > 0 {
            if parameter.searchType == .OR_EQUALS && parameter.target == "_ARE_PLAYING_"{
                var paramString = "("
                parameter.queryList.forEach { orItem in
                    if paramString.count > 1 {
                        paramString = "\(paramString) OR "
                    }
                    paramString = "\(paramString) homeTeam.id:\(orItem) OR awayTeam.id:\(orItem)"
                }
                return "\(paramString))"
            }
        }
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
    
    
    func baseURL() -> String {
        switch StreamAMGSDK.sdkEnvironment() {
        case .PRODUCTION:
            return "https://api.streamplay.streamamg.com/"
        default:
            return "https://staging.api.streamplay.streamamg.com/"
        }
    }
    /**
      Builder class for creating 'FEED' queries
     * It is preferred that a builder class is used to ensure all relevant information is included
     */
    public class FeedBuilder {
        var sportObject: [StreamPlaySport] = []
        var fixtureIDObject: String? = nil
        var partnerIDObject: String? = nil
        var paramsObject: [SearchParameter] = []
        var urlObject: String? = nil
        var paginateObject: Int = 0
        
        public init(){
            
        }
        /**
         Single 'StreamPlaySport' enum that should form the basis of the feed - should not be used with 'url'
         */
        public func sport(_ sport: StreamPlaySport) -> FeedBuilder {
            self.sportObject.append(sport)
            return self
        }
        /**
         Array list of 'StreamPlaySport' enums that should form the basis of the feed - should not be used with 'url'
         */
        public func sports(_ sports: [StreamPlaySport]) -> FeedBuilder {
            self.sportObject = sports
            return self
        }
        /**
         ID of the fixture being requested - should not be used with 'url'
         */
        public func fixture(_ fixtureID: String) -> FeedBuilder {
            self.fixtureIDObject = fixtureID
            return self
        }
        
        /**
         ID of the 'partner' making the request - should not be used with 'url'
         */
        
        public func partner(_ partnerID: String) -> FeedBuilder {
            self.partnerIDObject = partnerID
            return self
        }
        
        /**
         Adds a fully formed URL to the query - should not be used with other request items
         */
        public func url(_ url: String) -> FeedBuilder {
            self.urlObject = url
            return self
        }
        
        /**
         A requested number of items per page to be returned - default is 20
         */
        public func paginateBy(_ paginateBy: Int) -> FeedBuilder {
            self.paginateObject = paginateBy
            return self
        }
        
        /**
         Returns a StreamPlayRequest and logs to the console if this request is not valid
         */
        public func build() -> StreamPlayRequest {
            return StreamPlayRequest.init(sport: sportObject, fixtureID: fixtureIDObject, partnerID: partnerIDObject, params: paramsObject, url: urlObject, paginateBy: paginateObject)
        }
        
    }
    /**
     Builder class for creating 'SEARCH' queries
     * It is preferred that a builder class is used to ensure all relevant information is included
     */
    public class SearchBuilder {
        var sportObject: [StreamPlaySport] = []
        var partnerIDObject: String? = nil
        var paramsObject: [SearchParameter] = []
        var paginateObject: Int = 0
        var workableURL: String? = nil
        
        public init(){
            
        }
        
        public func url(_ url: String) -> SearchBuilder {
            // Strip 'feed' info from URL
//            if url.contains("?") {
//                if let index = url.index(of: "?") {
//                    let firstPart = url.prefix(upTo: index)
//                    workableURL = String(firstPart)
//                    return self
//                }
//            }
workableURL = url
            return self
        }
        
        
        /**
         Single 'StreamPlaySport' enum that should form the basis of the feed - should not be used with 'url'
         */
        public func sport(_ sport: StreamPlaySport) -> SearchBuilder {
            self.sportObject.append(sport)
            return self
        }
        
        /**
         Array list of 'StreamPlaySport' enums that should form the basis of the feed - should not be used with 'url'
         */
        public func sports(_ sports: [StreamPlaySport]) -> SearchBuilder {
            self.sportObject = sports
            return self
        }
        
        /**
         ID of the fixture being requested - should not be used with 'url'
         */
        public func partner(_ partnerID: String) -> SearchBuilder {
            self.partnerIDObject = partnerID
            return self
        }
        
        /**
         ID of the 'partner' making the request - should not be used with 'url'
         */
        public func parameters(_ parameters: [SearchParameter]) -> SearchBuilder {
            self.paramsObject.append(contentsOf: parameters)
            return self
        }
        
        /**
         Adds a fully formed URL to the query - should not be used with other request items
         */
        public func parameter(_ parameter: SearchParameter) -> SearchBuilder {
            self.paramsObject.append(parameter)
            return self
        }
        
        
        /**
         Adds an 'equality' check to the query that returns only items in which this field contains a complete word or string that matches the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isEqualTo(target: StreamPlayQueryField, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: query, queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) greater than the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThan(target: StreamPlayQueryField, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHAN, target: target.query(), query: query, queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) greater than or equal to the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThanOrEqualTo(target: StreamPlayQueryField, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHANOREQUALTO, target: target.query(), query: query, queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) less than the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThan(target: StreamPlayQueryField, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHAN, target: target.query(), query: query, queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a value (numerical or alphabetically) less than or equal to the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThanOrEqualTo(target: StreamPlayQueryField, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHANOREQUALTO, target: target.query(), query: query, queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds an 'equality' check to the query that returns only items in which this field contains a NSNumber equal to the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isEqualTo(target: StreamPlayQueryField, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "\(query)", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value less than the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThan(target: StreamPlayQueryField, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHAN, target: target.query(), query: "\(query)", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value greater than or equal to the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isGreaterThanOrEqualTo(target: StreamPlayQueryField, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .GREATERTHANOREQUALTO, target: target.query(), query: "\(query)", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value less than the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThan(target: StreamPlayQueryField, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHAN, target: target.query(), query: "\(query)", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'comparative' check to the query that returns only items in which this field contains a numerical value less than or equal to the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLessThanOrEqualTo(target: StreamPlayQueryField, query: NSNumber) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .LESSTHANOREQUALTO, target: target.query(), query: "\(query)", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'fuzzy' check to the query that returns only items in which this field where any word or continual string of the value contains the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func isLike(target: StreamPlayQueryField, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .FUZZY, target: target.query(), query: "*$query*", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'fuzzy' check to the query that returns only items in which this field where any word or continual string of the value starts with the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func startsWith(target: StreamPlayQueryField, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "$query*", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a 'fuzzy' check to the query that returns only items in which this field where any word or continual string of the value ends with the query
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         * @param query The actual data to query
         */
        public func endsWith(target: StreamPlayQueryField, query: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "*$query", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a boolean check to the query that returns only items in this field which are 'true'
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         */
        public func isTrue(target: StreamPlayQueryField) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "true", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         Adds a boolean check to the query that returns only items in this field which are 'false'
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         */
        public func isFalse(target: StreamPlayQueryField) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "false", queryType: target.queryType().rawValue))
            return self
        }
        
        /**
         * Indicates which field should be sorted by in ascending value
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         */
        public func sortByAscending(target: StreamPlayQueryField) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "sort=${target: target.query()}:asc", queryType: StreamPlayQueryType.EXTRA.rawValue))
            return self
        }
        
        /**
         * Indicates which field should be sorted by in descending value
         * @param target A 'StreamPlayQueryField' enum indicating the field to query
         */
        public func sortByDescending(target: StreamPlayQueryField) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: target.query(), query: "sort=${target: target.query()}:desc", queryType: StreamPlayQueryType.EXTRA.rawValue))
            return self
        }
        
        /**
         * Indicates that any date queries should use the 'End' date of the item
         */
        public func endDateEffective() -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: "", query: "dateField=endDate", queryType: StreamPlayQueryType.EXTRA.rawValue))
            return self
        }
        
        /**
         * Indicates that any date queries should use the 'Start' date of the item
         */
        public func startDateEffective() -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: "", query: "dateField=startDate", queryType: StreamPlayQueryType.EXTRA.rawValue))
            return self
        }
        
        /**
         Adds a date check to the query that returns only items where the 'effective' date is after the query
         */
        public func dateFrom(date: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: "", query: "from=$date", queryType: StreamPlayQueryType.EXTRA.rawValue))
            return self
        }
        
        /**
         Adds a date check to the query that returns only items where the 'effective' date is before the query
         */
        public func dateTo(date: String) -> SearchBuilder {
            self.paramsObject.append(SearchParameter(searchType: .EQUALS, target: "", query: "to=$date", queryType: StreamPlayQueryType.EXTRA.rawValue))
            return self
        }
        
        /**
         Filters only teams involved in the matches
         */
        public func teamsArePlaying(_ teamIDs: [Any]) -> SearchBuilder {
            if teamIDs.isEmpty {
                return self
            }
            self.paramsObject.append(SearchParameter(searchType: .OR_EQUALS, target: "_ARE_PLAYING_", query: "", queryType: StreamPlayQueryType.PARAMETER.rawValue, queryList: teamIDs))
            return self
        }
        
        
        /**
         A requested number of items per page to be returned - default is 20
         */
        public func paginateBy(_ paginateBy: Int) -> SearchBuilder {
            self.paginateObject = paginateBy
            return self
        }
        
        /**
         Returns a StreamPlayRequest and logs to the console if this request is not valid
         */
        public func build() -> StreamPlayRequest {
            let req = StreamPlayRequest.init(sport: sportObject, partnerID: partnerIDObject, params: paramsObject, url: workableURL, paginateBy: paginateObject)
            return req
        }
        
    }
    
}
