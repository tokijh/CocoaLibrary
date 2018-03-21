//
//  LibraryListViewModel.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

typealias LibrarySectionData = SectionModel<String, Library>

class LibraryListViewModel: BaseViewModel {
    
    // Event
    let viewWillAppear = PublishSubject<Void>()
    let didCellSelected = PublishSubject<Repository>()
    
    // UI
    let isLoading: Driver<Bool>
    let libraries: Driver<[LibrarySectionData]>
    
    init(libraryService: LibraryService = LibraryService()) {
        
        let onLoading = PublishSubject<Bool>()
        
        self.isLoading = onLoading.asDriver(onErrorJustReturn: false)
        self.libraries = Observable<Void>
            .merge([self.viewWillAppear])
            .do(onNext: { _ in onLoading.onNext(true) })
            .flatMapLatest { libraryService.load() }
            .map { [LibrarySectionData(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])
    }
}
