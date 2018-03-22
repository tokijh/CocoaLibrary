//
//  GithubSearch.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 21..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import ObjectMapper

class GithubSearch: Mappable {

    var totalCount: Int = 0
    var incompleteResults: Bool = false
    var items: [Github] = []
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        totalCount <- map["total_count"]
        incompleteResults <- map["incomplete_results"]
        items <- map["items"]
    }
}
