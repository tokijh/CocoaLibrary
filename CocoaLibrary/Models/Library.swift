//
//  Library.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

class Library {
    var name: String
    var property: Property
    
    init(name: String, property: Property) {
        self.name = name
        self.property = property
    }
    
    enum Property {
        case cocoaPods
        case github
    }
}
