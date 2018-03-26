//
//  StringPickerTableViewCell.swift
//  CocoaLibrary
//
//  Created by 윤중현 on 2018. 3. 24..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class StringPickerTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    func initView() {
        addSubViews()
        constraint()
    }
    
    func addSubViews() {
        self.addSubview(pickerView)
    }
    
    func constraint() {
        self.pickerView.snp.makeConstraints {
            $0.edges.equalTo(self).inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
    }
    
    func configure(items: [(Int, String)], selected: () -> Int, selectedHandler: ((Int) -> ())? = nil) {
        Observable.of(items.map({ $0.1 }))
            .bind(to: pickerView.rx.itemTitles) {
                return $1
            }
            .disposed(by: disposeBag)
        pickerView.rx.itemSelected
            .subscribe(onNext: {
                selectedHandler?($0.row)
            })
            .disposed(by: disposeBag)
        pickerView.selectRow(selected(), inComponent: 0, animated: false)
    }
}
