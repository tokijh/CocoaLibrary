//
//  GithubRepositorySearchOptionSectionData.swift
//  CocoaLibrary
//
//  Created by 윤중현 on 2018. 3. 24..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxDataSources

enum GithubRepositorySearchOptionSectionData {
    case language(languages: [Value])
    case sort(sorts: [Value])
}

extension GithubRepositorySearchOptionSectionData: SectionModelType {
    typealias Item = Value
    
    var items: [Value] {
        switch self {
        case .language(let languages): return languages
        case .sort(let sorts): return sorts
        }
    }
    
    enum Value {
        case language(language: [(Int, String)], selected: () -> Int, handler: ((Int) -> ())?)
        case sort(sort: [(Int, String)], selected: () -> Int, handler: ((Int) -> ())?)
    }
    
    init(original: GithubRepositorySearchOptionSectionData, items: [Value]) {
        self = original
    }
}
