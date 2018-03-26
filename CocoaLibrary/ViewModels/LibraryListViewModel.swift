//
//  LibraryListViewModel.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftDo
import RxDataSources

typealias LibrarySectionData = SectionModel<String, Library>

class LibraryListViewModel: BaseViewModel {
    
    // Event
    let viewWillAppear = PublishSubject<Void>()
    let didCellSelected = PublishSubject<Library>()
    
    // UI
    let isLoading: Driver<Bool>
    let libraries: Driver<[LibrarySectionData]>
    let pushVC: Driver<UIViewController?>
    
    init(libraryService: LibraryService = LibraryService()) {
        
        let onLoading = PublishSubject<Bool>()
        
        self.isLoading = onLoading.asDriver(onErrorJustReturn: false)
        self.libraries = Observable<Void>
            .merge([self.viewWillAppear])
            .do(onNext: { _ in onLoading.onNext(true) })
            .flatMapLatest { libraryService.load() }
            .map { [LibrarySectionData(model: "", items: $0)] }
            .do(on: { if !$0.isSubscribe, !$0.isSubscribed, !$0.isCompleted {  onLoading.onNext(false) } })
            .asDriver(onErrorJustReturn: [])
        
        self.pushVC = didCellSelected.map {
            switch $0.property {
            case .cocoaPods: return CocoaPodsListViewController.create(with: CocoaPodsListViewModel())
            case .github: return GithubListViewController.create(with: GithubListViewModel())
            }
        }.asDriver(onErrorJustReturn: nil)
    }
}
