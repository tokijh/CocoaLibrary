//
//  GithubList2ViewModel.swift
//  CocoaLibrary
//
//  Created by 윤중현 on 2018. 3. 25..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class GithubList2ViewModel: BaseViewModel {

    // Event
    let didTapRightTabButton = PublishSubject<Void>()
    let didTapOptionButton = PublishSubject<Void>()
    let didTapCancelButton = PublishSubject<Void>()
    let didTapSearchButton = PublishSubject<Void>()
    let changeSearchingText = PublishSubject<String>()
    let didTapCell = PublishSubject<Github>()
    
    // UI
    let isNetworking: Driver<Bool>
    let repositories: Driver<[GithubData]>
    let showAlert: Driver<(String, String)>
    let showRepository: Driver<URL?>
    let editSearchRepositoryOption: Driver<GithubSearchRepositoryOptionViewModel>
    
    init(githubService: GithubServiceType = GithubService(), repositoryOption: GithubServiceRepositoryOption = GithubServiceRepositoryOption(topic: "", language: .all, sort: .best)) {
        var currentRepositoryOption = repositoryOption
        
        let onNetworking = PublishSubject<Bool>()
        self.isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
        
        let onError = PublishSubject<Error?>()
        self.showAlert = onError
            .map { ("Error", $0?.localizedDescription ?? "Unknown Error") }
            .asDriver(onErrorJustReturn: ("Error", "Unknown Error"))
        
        let eventSearchingText = self.changeSearchingText
            .debounce(1, scheduler: MainScheduler.instance)
            .map({ $0.replacingOccurrences(of: " ", with: "%20") })
        
        let eventSearchingButton = self.didTapSearchButton
            .flatMapLatest({ eventSearchingText })
        
        let eventRepositoryOption = PublishSubject<GithubServiceRepositoryOption>()
        
        let combinedSearchingText = Observable<String>
            .merge([
                eventSearchingText,
                eventSearchingButton
            ])
            .map { text -> GithubServiceRepositoryOption in
                currentRepositoryOption.topic = text
                return currentRepositoryOption
            }
        
        let combinedSearchingOption = Observable<GithubServiceRepositoryOption>
            .merge([
                eventRepositoryOption,
                combinedSearchingText
            ])
            .map { option -> GithubServiceRepositoryOption in
                var new = option
                new.topic = currentRepositoryOption.topic
                currentRepositoryOption = new
                return currentRepositoryOption
            }
        
        let eventCancelSearch: Observable<[Github]> = didTapCancelButton.map({ [] })
        
        let eventSearch = combinedSearchingOption
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { _ in onNetworking.onNext(true) })
            .flatMapLatest { option -> Observable<[Github]> in
                return githubService
                    .repository(option: option)
                    .retry(1)
                    .catchError { Observable.of(.fail($0)) }
                    .map { (result) -> [Github] in
                        switch result {
                        case .success(let githubs): return githubs
                        case .fail(let error): onError.onNext(error); return []
                        }
                    }
            }
            .do { if !$0.isSubscribe, !$0.isSubscribed, !$0.isCompleted { print($0); onNetworking.onNext(false) } }
        
        self.repositories = Observable<[Github]>
            .merge([
                eventSearch,
                eventCancelSearch
            ])
            .map { [GithubData(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])
        
        self.showRepository = didTapCell.map({ URL(string: $0.html_url) }).asDriver(onErrorJustReturn: nil)
        
        self.editSearchRepositoryOption = Observable.merge([
                didTapRightTabButton,
                didTapOptionButton
            ])
            .map { _ in
                GithubSearchRepositoryOptionViewModel(option: currentRepositoryOption) {
                    eventRepositoryOption.onNext($0)
                }
            }
            .asDriver(onErrorJustReturn: GithubSearchRepositoryOptionViewModel(option: GithubServiceRepositoryOption(topic: "", language: .all, sort: .best)))
    }
}
