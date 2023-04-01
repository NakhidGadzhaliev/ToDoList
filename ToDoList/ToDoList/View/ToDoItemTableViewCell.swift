//
//  ToDoItemTableViewCell.swift
//  ToDoList
//
//  Created by Нахид Гаджалиев on 25.03.2023.
//

import UIKit

class ToDoItemTableViewCell: UITableViewCell {
    
    static let identifier = "ToDoItemTableViewCell"
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(title)
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
        ])
        
    }

}
