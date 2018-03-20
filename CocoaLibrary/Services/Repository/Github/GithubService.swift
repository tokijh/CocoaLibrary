//
//  GithubService.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import Foundation

protocol GithubServiceType: RepositoryService {
    func search(_ text: String)
}

class GithubService: GithubServiceType {
    func search(_ text: String) {
        // TODO add search logic
    }
}
