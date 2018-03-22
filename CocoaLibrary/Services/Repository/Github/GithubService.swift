//
//  GithubService.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift
import RxAlamofire

protocol GithubServiceType: RepositoryService {
    func fetch(option: GithubServiceOption) -> Observable<Result<[Github]>>
}

struct GithubServiceOption {
    var language: Language
    var sort: Sort
    
    enum Language: String {
        case all = "swift,objc", swift, objc
    }
    
    enum Sort: String {
        case stars, forks, updated
    }
}

class GithubService: GithubServiceType {
    func fetch(option: GithubServiceOption) -> Observable<Result<[Github]>> {
        let baseUrl = "https://api.github.com/search/repositories?q="
        let language = "language:\(option.language.rawValue)"
        let sort = "&sort=\(option.sort)"
        return json(.get, baseUrl + language + sort)
            .mapObject(type: GithubSearch.self)
            .map { $0.items }
            .map { Result.success($0) }
            .catchError { _ in Observable.of(Result<[Github]>.fail(nil)) }
    }
}
