//
//  Rx+Request.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 21..
//  Copyright © 2018년 tokijh. All rights reserved.
//

enum Result<Value> {
    case success(Value)
    case fail(Error?)
}
