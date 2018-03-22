//
//  GithubListViewController.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 20..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

class GithubListViewController: UIViewController, BaseViewType {
    
    var viewModel: GithubListViewModel!
    var disposeBag: DisposeBag!
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(GithubTableViewCell.self, forCellReuseIdentifier: GithubTableViewCell.Identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    
    func initView() {
        self.title = "Github"
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
    }
    
    func bindView() {
        self.viewModel.repositories
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.viewModel.showAlert
            .drive(onNext: { [weak self] in self?.alert(title: $0.0, message: $0.1) })
            .disposed(by: disposeBag)
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<GithubData> = {
        RxTableViewSectionedReloadDataSource<GithubData>(configureCell: { (dataSource, tableView, indexPath, github) -> UITableViewCell in
            if let cell = tableView.dequeue(GithubTableViewCell.self, indexPath: indexPath) {
                cell.configure(name: github.name, description: github.description, starsCount: github.starsCount, forksCount: github.forksCount)
                return cell
            }
            return UITableViewCell()
        })
    }()
}
