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

class GithubListViewModel: RepositoriesViewModelType {
    
    // Event
    let viewWillAppear = PublishSubject<Void>()
    
    // UI
    let isNetworking: Driver<Bool>
    let showAlert: Driver<(String, String)>
    let repositories: Driver<[GithubData]>
    
    init(githubService: GithubServiceType = GithubService(), githubServiceOption: GithubServiceOption) {
        let onNetworking = PublishSubject<Bool>()
        self.isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
        
        let onError = PublishSubject<Error?>()
        self.showAlert = onError
            .map { ("Error", $0?.localizedDescription ?? "Unknown Error") }
            .asDriver(onErrorJustReturn: ("Error", "Unknown Error"))
        
        self.repositories = Observable<Void>
            .merge([self.viewWillAppear])
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .do(onNext: { _ in onNetworking.onNext(true) })
            .flatMapLatest { _ in
                githubService.fetch(option: githubServiceOption)
                    .retry(1)
                    .catchErrorJustReturn(.fail(nil))
                    .map { (result) -> [Github] in
                        switch result {
                        case .success(let githubs): return githubs
                        case .fail(let error): onError.onNext(error); return []
                        }
                    }
            }
            .map { [GithubData(model: "", items: $0)] }
            .do(on: { if !$0.isSubscribe, !$0.isSubscribed { onNetworking.onNext(false) } })
            .asDriver(onErrorJustReturn: [])
            .debug()
    }
}
