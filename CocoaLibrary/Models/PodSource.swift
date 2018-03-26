//
//  PodSource.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 22..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import ObjectMapper

class PodSource: Mappable {
    var git: String = ""
    var tag: String = ""
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        git <- map["git"]
        tag <- map["tag"]
    }
}
