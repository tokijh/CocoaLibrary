//
//  CocoaPodsService.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift

protocol CocoaPodsServiceType: RepositoryService {
    func search(_ text: String) -> Observable<Result<[Pod]>>
}

class CocoaPodsService: CocoaPodsServiceType {
    func search(_ text: String) -> Observable<Result<[Pod]>> {
        return Observable.just(Result<[Pod]>.fail(nil))
    }
}
