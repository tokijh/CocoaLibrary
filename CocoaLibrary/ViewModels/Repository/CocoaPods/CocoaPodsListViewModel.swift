//
//  CocoaPodsListViewModel.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

typealias CocoaPodsData = SectionModel<String, Pod>

class CocoaPodsListViewModel: RepositoriesViewModelType {
    
    // Event
    let viewWillAppear = PublishSubject<Void>()
    
    // UI
    let isNetworking: Driver<Bool>
    let showAlert: Driver<(String, String)>
    let repositories: Driver<[CocoaPodsData]>
    
    init(cocoaPodsService: CocoaPodsServiceType = CocoaPodsService()) {
        let onNetworking = PublishSubject<Bool>()
        self.isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
        
        let onError = PublishSubject<Error?>()
        self.showAlert = onError
            .map { ("Error", $0?.localizedDescription ?? "Unknown Error") }
            .asDriver(onErrorJustReturn: ("Error", "Unknown Error"))
        
        self.repositories = Observable<Void>
            .merge([self.viewWillAppear])
            .do(onNext: { _ in onNetworking.onNext(true) })
            .flatMapLatest { _ in
                cocoaPodsService.search("")
                    .retry(1)
                    .catchErrorJustReturn(.fail(nil))
                    .map { (result) -> [Pod] in
                        switch result {
                        case .success(let pods): return pods
                        case .fail(let error): onError.onNext(error); return []
                        }
                    }
            }
            .map { [CocoaPodsData(model: "", items: $0)] }
            .do(on: { if !$0.isSubscribe, !$0.isSubscribed, !$0.isCompleted { onNetworking.onNext(false) } })
            .asDriver(onErrorJustReturn: [])
    }
}
