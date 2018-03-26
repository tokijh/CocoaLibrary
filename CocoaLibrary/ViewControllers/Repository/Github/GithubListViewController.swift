//
//  GithubListViewController.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 26..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import SafariServices

class GithubListViewController: UIViewController, BaseViewType {
    
    var viewModel: GithubListViewModel!
    var disposeBag: DisposeBag!
    
    lazy var searchController: UISearchController = { [unowned self] in
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = true // SearchBar를 클릭하면 navigationBar가 숨겨진다
        searchController.dimsBackgroundDuringPresentation = false // 검색중에 뒤가 흐려진다
        searchController.obscuresBackgroundDuringPresentation = false // SearchBar에서 문자 입력시 바로 searchResultsController를 활용하여 결과를 표시해준다 (Apple에서 검색대상의 리스트와 검색결과를 표시하는 리스트가 같은 VC라면 false로 하라고 나와있음)
        searchController.searchBar.placeholder = "Search Github"
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(#imageLiteral(resourceName: "img_setting"), for: .bookmark, state: .normal)
        return searchController
        }()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(GithubTableViewCell.self, forCellReuseIdentifier: GithubTableViewCell.Identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    lazy var rightBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = #imageLiteral(resourceName: "img_setting")
        return item
    }()
    lazy var indicatorView: UIActivityIndicatorView = { [weak self] in
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.color = UIColor.gray
        if let center = self?.view.center {
            indicator.center = center
        }
        return indicator
        }()
    
    func initView() {
        self.title = "Github"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        addSubViews()
        constraint()
    }
    
    func addSubViews() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.indicatorView)
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
        self.searchController.searchBar.rx.text.orEmpty.bind(to: viewModel.searchingText).disposed(by: disposeBag)
        self.rightBarButtonItem.rx.tap.bind(to: viewModel.didTapRightTabButton).disposed(by: disposeBag)
        self.searchController.searchBar.rx.bookmarkButtonClicked.bind(to: viewModel.didTapOptionButton).disposed(by: disposeBag)
        self.searchController.searchBar.rx.searchButtonClicked.bind(to: viewModel.didTapSearchButton).disposed(by: disposeBag)
        self.searchController.searchBar.rx.cancelButtonClicked.bind(to: viewModel.didTapCancelButton).disposed(by: disposeBag)
        self.tableView.rx.modelSelected(Github.self).bind(to: viewModel.didTapCell).disposed(by: disposeBag)
        self.tableView.rx.reachedBottom
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)
    }
    
    func bindView() {
        NotificationCenter.default.rx
            .notification(Notification.Name.UIKeyboardWillShow)
            .subscribe { [weak self] in
                guard let frame = ($0.element?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
                self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0) }
            .disposed(by: disposeBag)
        NotificationCenter.default.rx
            .notification(Notification.Name.UIKeyboardWillHide)
            .subscribe { [weak self] _ in
                self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }
            .disposed(by: disposeBag)
        
        self.viewModel.repositories
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.viewModel.showAlert
            .drive(onNext: { [weak self] in
                self?.alert(title: $0.0, message: $0.1)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.isNetworking
            .drive(onNext: { [weak self] in self?.showIndicator($0) })
            .disposed(by: disposeBag)
        
        self.viewModel.showRepository
            .drive(onNext: { [weak self] in
                guard let url = $0 else { return }
                let safariViewController = SFSafariViewController(url: url)
                self?.present(safariViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.editSearchRepositoryOption
            .drive(onNext: { [weak self] in
                self?.navigationController?.pushViewController(GithubSearchRepositoryOptionViewController.create(with: $0), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    func showIndicator(_ showing: Bool) {
        if showing { indicatorView.startAnimating() }
        else { indicatorView.stopAnimating() }
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
