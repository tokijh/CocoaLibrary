//
//  CocoaPodsListViewController.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CocoaPodsListViewController: UIViewController, BaseViewType {
    
    var viewModel: CocoaPodsListViewModel!
    var disposeBag: DisposeBag!
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = true // SearchBar를 클릭하면 navigationBar가 숨겨진다
        searchController.dimsBackgroundDuringPresentation = false // 검색중에 뒤가 흐려진다
        searchController.obscuresBackgroundDuringPresentation = false // SearchBar에서 문자 입력시 바로 searchResultsController를 활용하여 결과를 표시해준다 (Apple에서 검색대상의 리스트와 검색결과를 표시하는 리스트가 같은 VC라면 false로 하라고 나와있음)
        searchController.searchBar.placeholder = "Search CocoaPods"
        return searchController
    }()
    lazy var tableView: UITableView = { [weak self] in
        let tableView = UITableView()
        tableView.register(PodTableViewCell.self, forCellReuseIdentifier: PodTableViewCell.Identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    
    func initView() {
        self.title = "CocoaPods"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        addSubViews()
        constraint()
    }
    
    func addSubViews() {
        self.view.addSubview(self.tableView)
    }
    
    func constraint() {
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.left.equalTo(self.view)
            $0.right.equalTo(self.view)
            $0.bottom.equalTo(self.view)
        }
    }
    
    func bindEvent() {
        self.rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        self.searchController.searchBar.rx.text.bind(to: viewModel.changeSearchingText).disposed(by: disposeBag)
        self.rx.viewWillAppear.map { _ in nil }.bind(to: viewModel.changeSearchingOption).disposed(by: disposeBag)
    }
    
    func bindView() {
        self.viewModel.repositories
            .debug()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<CocoaPodsData> = {
        RxTableViewSectionedReloadDataSource<CocoaPodsData>(configureCell: { (dataSource, tableView, indexPath, pod) -> UITableViewCell in
            if let cell = tableView.dequeue(PodTableViewCell.self, indexPath: indexPath) {
                cell.configure(name: pod.id, description: pod.summary, version: pod.version, tags: pod.tags)
                return cell
            }
            return UITableViewCell()
        })
    }()
}
