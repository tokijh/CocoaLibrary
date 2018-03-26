//
//  PodTableViewCell.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 22..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit
import SnapKit
import TagListView

class PodTableViewCell: UITableViewCell {
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    lazy var tagListView: TagListView = {
        let tags = TagListView()
        return tags
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
        self.addSubview(descriptionLabel)
        self.addSubview(tagListView)
    }
    
    func constraint() {
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self).offset(15)
            $0.left.equalTo(self).offset(15)
            $0.right.equalTo(self).offset(-15)
        }
        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.left.equalTo(self).offset(15)
            $0.right.equalTo(self).offset(-15)
        }
        self.tagListView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(5)
            $0.left.equalTo(self).offset(15)
            $0.right.equalTo(self).offset(-15)
            $0.bottom.equalTo(self).offset(-15)
        }
    }
    
    func configure(name: String, description: String, version: String? = nil, tags: [String]) {
        let nameText =
            NSMutableAttributedString(string: name)
        if let version = version, version.count > 0 {
        nameText.append(
            NSMutableAttributedString(
                string: " \(version)",
                attributes: [
                    .foregroundColor: UIColor.gray
                ]))
        }
        self.nameLabel.attributedText = nameText
        self.descriptionLabel.text = description
        self.tagListView.removeAllTags()
        self.tagListView.addTags(tags)
    }
}
