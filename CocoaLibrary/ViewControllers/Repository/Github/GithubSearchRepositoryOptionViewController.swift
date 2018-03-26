//
//  GithubSearchRepositoryOptionViewController.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 23..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

class GithubSearchRepositoryOptionViewController: UIViewController, BaseViewType {
    
    var viewModel: GithubSearchRepositoryOptionViewModel!
    var disposeBag: DisposeBag!
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cell: StringPickerTableViewCell.self, forCellReuseIdentifier: StringPickerTableViewCell.Identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return tableView
    }()
    lazy var rightBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.title = "Save"
        return item
    }()
    
    func initView() {
        self.title = "Github Repository Search Option"
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        addSubViews()
        constraint()
    }
    
    func addSubViews() {
        self.view.addSubview(self.tableView)
    }
    
    func constraint() {
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            $0.left.equalTo(self.view)
            $0.right.equalTo(self.view)
            $0.bottom.equalTo(self.view)
        }
    }
    
    func bindEvent() {
        self.rightBarButtonItem.rx.tap.bind(to: viewModel.didTapSaveBarButton).disposed(by: disposeBag)
    }
    
    func bindView() {
        self.viewModel.settingItems
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.viewModel.popViewController
            .drive(onNext: { [weak self] in
                guard $0 else { return }
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<GithubRepositorySearchOptionSectionData> = { [weak self] in
        return RxTableViewSectionedReloadDataSource(configureCell: { [weak self] (dataSource, tableView, indexPath, value) -> UITableViewCell in
            guard let cell = tableView.dequeue(StringPickerTableViewCell.self, indexPath: indexPath) else { return UITableViewCell() }
            switch dataSource[indexPath] {
            case .language(let languages, let selected, let handler):
                cell.configure(items: languages, selected: selected, selectedHandler: handler)
            case .sort(let sorts, let selected, let handler):
                cell.configure(items: sorts, selected: selected, selectedHandler: handler)
            }
            return cell
        }, titleForHeaderInSection: { (dataSource, section) -> String? in
            switch section {
            case 0: return "Language"
            case 1: return "Sort"
            default: return nil
            }
        })
    }()
}
