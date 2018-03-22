//
//  Pod.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 21..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import ObjectMapper

class Pod: Repository, Mappable {
    var name: String = ""
    var description: String = ""
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        name <- map["name"]
        description <- map["description"]
    }
}
