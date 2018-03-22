//
//  RepositoriesViewModel.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

protocol RepositoriesViewModelType: BaseViewModel {
    
    associatedtype Model
    
    // Event
    var viewWillAppear: PublishSubject<Void> { get }
//    var didTapLeftBarButton: PublishSubject<Void> { get }
//    var didTapRightBarButton: PublishSubject<Void> { get }
//    var didPulltoRefresh: PublishSubject<Void> { get }
//    var didCellSelected: PublishSubject<Repository> { get }
//
    // UI
    var isNetworking: Driver<Bool> { get }
    var showAlert: Driver<(String, String)> { get }
    var repositories: Driver<[SectionModel<String, Model>]> { get }
//    var editSetting: Driver<SettingViewModelType>
//    var showRepository: Driver<String> { get }
}
