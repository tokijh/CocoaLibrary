//
//  GithubTableViewCell.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 21..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit
import SnapKit

class GithubTableViewCell: UITableViewCell {
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
    lazy var starsImageView: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "img_star")
        return image
    }()
    lazy var starsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    lazy var forksImageView: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "img_fork")
        return image
    }()
    lazy var forksCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
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
        self.selectionStyle = .none
        addSubViews()
        constraint()
    }
    
    func addSubViews() {
        self.addSubview(nameLabel)
        self.addSubview(descriptionLabel)
        self.addSubview(starsImageView)
        self.addSubview(starsCountLabel)
        self.addSubview(forksImageView)
        self.addSubview(forksCountLabel)
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
        self.starsImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(5)
            $0.left.equalTo(self).offset(15)
            $0.bottom.equalTo(self).offset(-15)
            $0.width.equalTo(23)
            $0.height.equalTo(starsImageView.snp.width).multipliedBy(1)
        }
        self.starsCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(starsImageView.snp.centerY)
            $0.left.equalTo(starsImageView.snp.right).offset(5)
        }
        self.forksImageView.snp.makeConstraints {
            $0.centerY.equalTo(starsCountLabel.snp.centerY)
            $0.left.equalTo(starsCountLabel.snp.right).offset(15)
            $0.width.equalTo(23)
            $0.height.equalTo(forksImageView.snp.width).multipliedBy(1)
        }
        self.forksCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(forksImageView.snp.centerY)
            $0.left.equalTo(forksImageView.snp.right).offset(5)
        }
    }
    
    func configure(name: String, description: String, starsCount: Int, forksCount: Int) {
        self.nameLabel.text = name
        self.descriptionLabel.text = description
        self.starsCountLabel.text = "\(starsCount)"
        self.forksCountLabel.text = "\(forksCount)"
    }
}
