//
//  GithubListViewModel.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

typealias GithubData = SectionModel<String, Github>

class GithubListViewModel: BaseViewModel {
    
    // Event
    let didTapRightBarButtonItem = PublishSubject<Void>()
    let searchingText = BehaviorRelay<String?>(value: nil)
    let didTapSearchButton = PublishSubject<Void>()
    let cancelSearch = PublishSubject<Void>()
    
    // UI
    let isNetworking: Driver<Bool>
    let showAlert: Driver<(String, String)>
    let repositories: Driver<[GithubData]>
    let editSearchRepositoryOption: Driver<GithubSearchRepositoryOptionViewModel>
    
    init(githubService: GithubServiceType = GithubService(), searchingRepositoryOption: GithubServiceRepositoryOption = GithubServiceRepositoryOption.init(topic: "", language: .all, sort: .best, page: 0)) {
        var searchingRepositoryOption = searchingRepositoryOption
        
        let onNetworking = PublishSubject<Bool>()
        self.isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
        
        let onError = PublishSubject<Error?>()
        self.showAlert = onError
            .map { ("Error", $0?.localizedDescription ?? "Unknown Error") }
            .asDriver(onErrorJustReturn: ("Error", "Unknown Error"))

        let searchingText = self.searchingText
        
        let eventSearching = searchingText
            .flatMapLatest { text -> Observable<String> in
                guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), text.count > 0 else { return Observable.empty() }
                return Observable.just(text)
            }
            .debounce(1, scheduler: MainScheduler.instance)
        
        let eventRepositoryOption = PublishSubject<GithubServiceRepositoryOption>()
        
        let eventRepositorySearching = Observable<GithubServiceRepositoryOption>
            .merge([
                eventSearching.map {
                    searchingRepositoryOption.topic = $0
                    return searchingRepositoryOption
                },
                eventRepositoryOption.map {
                    var new = $0
                    new.topic = searchingRepositoryOption.topic
                    searchingRepositoryOption = new
                    return searchingRepositoryOption
                },
                didTapSearchButton
                    .flatMapLatest({ searchingText })
                    .flatMap { text -> Observable<String> in
                        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), text.count > 0 else { return Observable.empty() }
                        return Observable.just(text)
                    }
                    .map {
                        searchingRepositoryOption.topic = $0
                        return searchingRepositoryOption
                    }
            ])
        
        let searched = eventRepositorySearching
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
        
        self.repositories = Observable<[Github]>
            .merge([
                searched,
                cancelSearch.map({ [] })
            ])
            .map { [GithubData(model: "", items: $0)] }
            .do(on: { if !$0.isSubscribe, !$0.isSubscribed, !$0.isCompleted { onNetworking.onNext(false) } })
            .asDriver(onErrorJustReturn: [])
        
        self.editSearchRepositoryOption = didTapRightBarButtonItem
            .map { _ in
                GithubSearchRepositoryOptionViewModel(option: searchingRepositoryOption) {
                    eventRepositoryOption.onNext($0)
                }
            }
            .asDriver(onErrorJustReturn: GithubSearchRepositoryOptionViewModel(option: GithubServiceRepositoryOption(topic: "", language: .all, sort: .best, page: 0)))
    }
}
