//
//  Github.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 21..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import ObjectMapper

class Github: Repository, Mappable {
    var name: String = ""
    var description: String = ""
    var starsCount: Int = 0
    var forksCount: Int = 0
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        name <- map["name"]
        description <- map["description"]
        forksCount <- map["forks_count"]
        starsCount <- map["stargazers_count"]
    }
}
