//
//  GithubSearchRepositoryOptionViewModel.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 23..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift
import RxCocoa

class GithubSearchRepositoryOptionViewModel: BaseViewModel {
    
    // Event
    let didTapSaveBarButton = PublishSubject<Void>()
    
    // UI
    let settingItems: Driver<[GithubRepositorySearchOptionSectionData]>
    let popViewController: Driver<Bool>
    
    init(option: GithubServiceRepositoryOption, completion: ((GithubServiceRepositoryOption) -> ())? = nil) {
        
        var currentOption = option
        
        self.settingItems = Observable<[GithubRepositorySearchOptionSectionData]>
            .from(optional: [
                .language(languages: [
                    .language(
                        language: GithubServiceRepositoryOption
                            .Language
                            .getAll
                            .enumerated()
                            .map {
                                if $0.element == .all {
                                    return ($0.offset, "all")
                                }
                                return ($0.offset, $0.element.rawValue)
                            },
                        selected: { currentOption.language.hashValue },
                        handler: { currentOption.language = GithubServiceRepositoryOption.Language.fromInt($0) ?? currentOption.language }
                    )
                ]),
                .sort(sorts: [
                    .sort(
                        sort: GithubServiceRepositoryOption
                            .Sort
                            .getAll
                            .enumerated()
                            .map { ($0.offset, $0.element.rawValue) },
                        selected: { currentOption.sort.hashValue },
                        handler: { currentOption.sort = GithubServiceRepositoryOption.Sort.fromInt($0) ?? currentOption.sort }
                    )
                ])
            ])
            .asDriver(onErrorJustReturn: [])
        
        self.popViewController = self.didTapSaveBarButton
            .do(onNext: { _ in completion?(currentOption) })
            .map({ true })
            .asDriver(onErrorJustReturn: true)
    }
}
