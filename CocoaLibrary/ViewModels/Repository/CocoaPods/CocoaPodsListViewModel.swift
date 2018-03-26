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
    let changeSearchingText = PublishSubject<String?>()
    let changeSearchingOption = PublishSubject<CocoaPodsServiceOption?>()
    
    // Value
    let searchingOption: Observable<CocoaPodsServiceOption?>
    
    // UI
    let isNetworking: Driver<Bool>
    let showAlert: Driver<(String, String)>
    let repositories: Driver<[CocoaPodsData]>
    let searchingText: Driver<String?>
    
    init(cocoaPodsService: CocoaPodsServiceType = CocoaPodsService()) {
        let onNetworking = PublishSubject<Bool>()
        self.isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
        
        let onError = PublishSubject<Error?>()
        self.showAlert = onError
            .map { ("Error", $0?.localizedDescription ?? "Unknown Error") }
            .asDriver(onErrorJustReturn: ("Error", "Unknown Error"))
        
        self.searchingOption = Observable
            .combineLatest(self.changeSearchingOption,
                           self.changeSearchingText.map { text -> String? in if let text = text { return text.count > 0 ? text : nil }; return nil }
                            .debounce(1, scheduler: SerialDispatchQueueScheduler(qos: .background))
            ) {
                guard let text = $1 else { return nil }
                var option = $0 ?? CocoaPodsServiceOption(query: text, offset: 0, ids: 20, language: .all, platform: .all, sort: .quality)
                option.query = text
                return option
            }
        
        self.searchingText = self.searchingOption.map { $0?.query }.asDriver(onErrorJustReturn: nil).debug()
        
        self.repositories = self.searchingOption
            .do(onNext: { _ in onNetworking.onNext(true) })
            .flatMapLatest { option -> Observable<[Pod]> in
                guard let option = option else { return Observable.of([]) }
                return cocoaPodsService.search(option)
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
