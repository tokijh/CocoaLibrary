//
//  Pod.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 21..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import ObjectMapper

class Pod: Repository, Mappable {
    var id: String = ""
    var platforms: [String] = []
    var version: String = ""
    var summary: String = ""
    var authors: [String : String] = [:]
    var link: String = ""
    var source: PodSource? = nil
    var tags: [String] = []
    var cocoadocs: Bool = false
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        id <- map["id"]
        platforms <- map["platforms"]
        version <- map["version"]
        summary <- map["summary"]
        authors <- map["authors"]
        link <- map["link"]
        source <- map["source"]
        tags <- map["tags"]
        cocoadocs <- map["cocoadocs"]
    }
}
