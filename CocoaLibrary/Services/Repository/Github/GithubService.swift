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
    func repository(option: GithubServiceRepositoryOption) -> Observable<Result<[Github]>>
}

struct GithubServiceRepositoryOption {
    var topic: String
    var language: Language
    var sort: Sort

    enum Language: String {
        case all = "", swift, objc
        public static var getAll: [Language] { return [.all, .swift, .objc] }
        public static var getAllWithIdx: EnumeratedSequence<Array<Language>> { return getAll.enumerated() }
        public static func fromInt(_ num: Int) -> Language? {
            switch num {
            case 0: return .all
            case 1: return .swift
            case 2: return .objc
            default: return nil
            }
        }
    }

    enum Sort: String {
        case best, stars, forks, updated
        public static var getAll: [Sort] { return [.best, .stars, .forks, .updated] }
        public static var getAllWithIdx: EnumeratedSequence<Array<Sort>> { return getAll.enumerated() }
        public static func fromInt(_ num: Int) -> Sort? {
            switch num {
            case 0: return .best
            case 1: return .stars
            case 2: return .forks
            case 3: return .updated
            default: return nil
            }
        }
    }
}

class GithubService: GithubServiceType {
    func repository(option: GithubServiceRepositoryOption) -> Observable<Result<[Github]>> {
        let baseUrl = "https://api.github.com/search/repositories?q="
        let topic = "topic:\(option.topic)"
        let language = option.language != .all ? " language:\(option.language.rawValue)" : ""
        let sort = option.sort != .best ? "&sort=\(option.sort)" : ""
        let url = (baseUrl + topic + language + sort).replacingOccurrences(of: " ", with: "%20")
        print(url)
        return json(.get, url)
            .mapObject(type: GithubSearch.self)
            .map { $0.items }
            .map { Result.success($0) }
            .catchError { Observable.of(Result<[Github]>.fail($0)) }
    }
}
