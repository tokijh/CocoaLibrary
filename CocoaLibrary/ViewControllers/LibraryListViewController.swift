//
//  LibraryListViewController.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxDataSources

class LibraryListViewModelController: UIViewController, BaseViewType {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LibraryTableViewCell.self, forCellReuseIdentifier: LibraryTableViewCell.Identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    
    var viewModel: LibraryListViewModel!
    var disposeBag: DisposeBag!
    
    func initView() {
        self.title = "LibraryList"
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
        
        tableView.rx.modelSelected(LibrarySectionData.Item.self)
            .bind(to: viewModel.didCellSelected)
            .disposed(by: disposeBag)
    }
    
    func bindView() {
        self.viewModel.libraries
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.viewModel.pushVC
            .drive(onNext: { [weak self] in
                guard let vc = $0 else { return }
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<LibrarySectionData> = {
        RxTableViewSectionedReloadDataSource<LibrarySectionData>(configureCell: { (dataSource, tableView, indexPath, library) -> UITableViewCell in
            if let cell = tableView.dequeue(LibraryTableViewCell.self, indexPath: indexPath) {
                cell.configure(name: library.name)
                return cell
            }
            return UITableViewCell()
        })
    }()
}
