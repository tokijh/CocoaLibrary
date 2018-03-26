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
    
    let disposeBag = DisposeBag()
    
    // Event
    let didTapRightTabButton = PublishSubject<Void>()
    let didTapOptionButton = PublishSubject<Void>()
    let didTapCancelButton = PublishSubject<Void>()
    let didTapSearchButton = PublishSubject<Void>()
    let didTapCell = PublishSubject<Github>()
    let loadNextPageTrigger = PublishSubject<Void>()
    
    // Value
    let searchingText = BehaviorRelay<String>(value: "")
    let githubs = BehaviorRelay<[Github]>(value: [])
    
    // UI
    let repositories: Driver<[GithubData]>
    let isNetworking: Driver<Bool>
    let showAlert: Driver<(String, String)>
    let showRepository: Driver<URL?>
    let editSearchRepositoryOption: Driver<GithubSearchRepositoryOptionViewModel>
    
    init(githubService: GithubServiceType = GithubService(), repositoryOption: GithubServiceRepositoryOption = GithubServiceRepositoryOption(topic: "", language: .all, sort: .best, page: 1)) {
        var hasNextPage: Bool = false
        var currentRepositoryOption = repositoryOption
        let githubs = self.githubs
        
        let onNetworking = PublishSubject<Bool>()
        self.isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
        
        let onError = PublishSubject<Error?>()
        self.showAlert = onError
            .map { ("Error", $0?.localizedDescription ?? "Unknown Error") }
            .asDriver(onErrorJustReturn: ("Error", "Unknown Error"))
        
        let seachingText = self.searchingText
            .debounce(0.5, scheduler: MainScheduler.instance)
            .map({ $0.replacingOccurrences(of: " ", with: "%20") })
        
        let eventSearching = self.didTapSearchButton
            .flatMapLatest({ seachingText })
        
        let combinedSearchingText = Observable.merge([
            seachingText,
            eventSearching
            ])
        
        let eventRepositoryOption = PublishSubject<GithubServiceRepositoryOption>()
        
        let combinedSearchingOption = Observable<GithubServiceRepositoryOption>
            .merge([
                eventRepositoryOption,
                combinedSearchingText
                    .map { text -> GithubServiceRepositoryOption in
                        currentRepositoryOption.topic = text
                        return currentRepositoryOption
                }
            ])
            .map { option -> GithubServiceRepositoryOption in
                var new = option
                new.topic = currentRepositoryOption.topic
                currentRepositoryOption = new
                // Init Paging
                currentRepositoryOption.page = 1
                hasNextPage = true
                return currentRepositoryOption
        }
        
        let eventEmptySearch: Observable<[Github]> = didTapCancelButton.map({ [] })
        
        let searching = PublishSubject<GithubServiceRepositoryOption>()
        combinedSearchingOption.bind(to: searching).disposed(by: disposeBag)
        
        let searchRepositories: (GithubServiceRepositoryOption) -> Observable<[Github]> = {
            return Observable.just($0)
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
                .do { if !$0.isSubscribe, !$0.isSubscribed, !$0.isCompleted { onNetworking.onNext(false) } }
        }
        
        let eventSearch = searching
            .flatMapLatest { searchRepositories($0) }
        
        let eventLoadMoreRepositories = self.loadNextPageTrigger
            .debounce(0.5, scheduler: MainScheduler.instance)
            .flatMap { void -> Observable<Void> in
                if hasNextPage { return Observable.just(void) }
                else { return Observable.empty() }
            }
            .map { _ -> GithubServiceRepositoryOption in
                currentRepositoryOption.page += 1
                return currentRepositoryOption
            }
            .flatMapLatest { searchRepositories($0) }
        
        eventLoadMoreRepositories
            .subscribe(onNext: {
                if $0.count == 0 { hasNextPage = false }
                githubs.accept(githubs.value + $0)
            })
            .disposed(by: disposeBag)
        
        Observable<[Github]>
            .merge([
                eventSearch,
                eventEmptySearch,
                ])
            .bind(to: githubs)
            .disposed(by: disposeBag)
        
        self.repositories = githubs.map({ [GithubData(model: "", items: $0)] }).asDriver(onErrorJustReturn: [])
        
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
            .asDriver(onErrorJustReturn: GithubSearchRepositoryOptionViewModel(option: GithubServiceRepositoryOption(topic: "", language: .all, sort: .best, page: 1)))
    }
}
