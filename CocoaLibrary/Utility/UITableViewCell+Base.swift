//
//  UITableViewCell+Base.swift
//  CocoaLibrary
//
//  Created by tokijh on 2018. 3. 21..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit

protocol TableViewCellType {
    static var Identifier: String { get }
}

extension UITableViewCell: TableViewCellType {
    static var Identifier: String { return String(describing: self.self) }
}

extension UITableView {
    func register<Cell>(cell: Cell.Type, forCellReuseIdentifier reuseIdentifier: String = Cell.Identifier) where Cell: UITableViewCell {
        register(cell, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func dequeue<Cell>(_ reusableCell: Cell.Type) -> Cell? where Cell: UITableViewCell {
        return dequeueReusableCell(withIdentifier: reusableCell.Identifier) as? Cell
    }
    
    func dequeue<Cell>(_ resusableCell: Cell.Type, indexPath: IndexPath) -> Cell? where Cell: UITableViewCell {
        return dequeueReusableCell(withIdentifier: resusableCell.Identifier, for: indexPath) as? Cell
    }
}
