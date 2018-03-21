//
//  CocoaPodsService.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

protocol CocoaPodsServiceType: RepositoryService {
    func search(_ text: String)
}

class CocoaPodsService: CocoaPodsServiceType {
    func search(_ text: String) {
        // TODO add search logic
    }
}
