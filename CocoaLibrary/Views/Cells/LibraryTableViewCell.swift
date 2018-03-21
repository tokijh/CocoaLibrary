//
//  LibraryTableViewCell.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 21..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit
import SnapKit

class LibraryTableViewCell: UITableViewCell {
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        addSubViews()
        constraint()
    }
    
    func addSubViews() {
        self.addSubview(nameLabel)
    }
    
    func constraint() {
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self).offset(15)
            $0.left.equalTo(self).offset(15)
            $0.right.greaterThanOrEqualTo(self).offset(-15)
            $0.bottom.equalTo(self).offset(-15)
        }
    }
    
    func configure(name: String) {
        self.nameLabel.text = name
    }
}
