//
//  CocoaPodsService.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift
import RxAlamofire

protocol CocoaPodsServiceType: RepositoryService {
    func search(_ option: CocoaPodsServiceOption) -> Observable<Result<[Pod]>>
}

struct CocoaPodsServiceOption {
    var query: String
    var offset: Int
    var ids: Int
    var language: Language
    var platform: Platform
    var sort: Sort
    
    enum Language {
        case all, swift, objc
    }
    
    enum Platform {
        case all, ios, macOS, watchOS, tvOS
    }
    
    enum Sort: String {
        case quality, popularity, name, contributors, forks, stars, watchers
    }
}

class CocoaPodsService: CocoaPodsServiceType {
    func search(_ option: CocoaPodsServiceOption) -> Observable<Result<[Pod]>> {
        let url = "https://aws-search.cocoapods.org/api/v1/pods.picky.hash.json?"
        let language: String
        switch option.language {
        case .all: language = ""
        case .swift: language = "%20lang%3Aswift"
        case .objc: language = "%20lang%3Aobjc"
        }
        let platform: String
        switch option.platform {
        case .all: platform = ""
        case .ios: platform = "%20on%3Aios"
        case .macOS: platform = "%20on%3Amacos"
        case .watchOS: platform = "%20on%3Awatchos"
        case .tvOS: platform = "%20on%3Atvos"
        }
        let query = "query=\(language)\(platform)\(option.query)&ids=\(option.ids)&offset=\(option.offset)&sort=\(option.sort)"
        print(url + query)
        return json(.get, url + query)
            .map { result -> Any in
                guard let json = result as? [String : AnyObject],
                    let allocations = json["allocations"] as? [Any],
                    allocations.count > 0,
                    let allocationItems = allocations[0] as? [Any],
                    allocationItems.count > 5
                    else {
                        throw NSError(
                            domain: "",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "ObjectMapper can't mapping"]
                        )
                        
                }
                return allocationItems[5]
            }
            .mapArray(type: Pod.self)
            .map { Result.success($0) }
            .catchError { Observable.of(Result<[Pod]>.fail($0)) }
    }
}
