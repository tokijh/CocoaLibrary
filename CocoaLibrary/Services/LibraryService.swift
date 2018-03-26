//
//  LibraryService.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift

class LibraryService {
    func load() -> Observable<[Library]> {
        return Observable.of([
            Library(name: "CocoaPods", property: .cocoaPods),
            Library(name: "Github", property: .github),
        ])
    }
}
