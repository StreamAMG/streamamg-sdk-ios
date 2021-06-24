//
//  SearchParameter.swift
//  StreamSDK-Core
//
//  Created by Mike Hall on 21/01/2021.
//

import Foundation

/**
 Model containing a single search parameter
 */
public struct SearchParameter {
    public var searchType: StreamAMGQueryType = StreamAMGQueryType.EQUALS
    public var target: String
    public var query: String
    public var typeDescription: String = ""
    public var queryType: Int = -1
    public var queryList: [Any] = []
    
    /**
     * @param searchType An object of type StreamAMGQueryType that represents the operand of the search parameter
     * @param target The field in the respective database to search - Represented as a String here, but generally translated from one of the module's search types
     * @param query The actual search term
     * @param typeDescription descriptive text for displaying in a search list - not required unless displaying in app - will use default text if using one of the module's search types
     * @param queryType An indicator of the type of search in StreamPlay - Not required in CloudMatrix
     */
    public init (searchType: StreamAMGQueryType, target: String, query: String, typeDescription: String = "", queryType: Int = -1, queryList: [Any] = []){
        self.searchType = searchType
        self.target = target
        self.query = query
        self.typeDescription = typeDescription
        self.queryType = queryType
        self.queryList = queryList
    }
}
