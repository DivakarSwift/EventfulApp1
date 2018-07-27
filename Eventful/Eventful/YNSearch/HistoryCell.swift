//
//  HistoryCell.swift
//  Eventful
//
//  Created by Mohammed Abubaker on 7/23/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Foundation

protocol DeleteButtonDelegate{
    func deleteButtonTaped(at index:IndexPath)
}

class HistoryCell: UITableViewCell {
    
    let icon : UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "search_history")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font =  UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    lazy var deleteButton : UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "close"), for: .normal)
        button.addTarget(self, action: #selector(deleteRow), for: .touchUpInside)
        return button
    }()
    
    
    var indexPath : IndexPath!
    var delegate:DeleteButtonDelegate?
    //var deleteRow : (() -> Void)? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    @objc func setupViews(){
        selectionStyle = .none
        
        addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.width.equalTo(20.0)
            make.height.equalTo(15.0)
            make.left.equalToSuperview()
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-8.0)
                make.width.equalTo(20.0)
                make.height.equalTo(15.0)
                make.centerY.equalTo(contentView.snp.centerY)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(icon.snp.right).offset(8.0)
            make.right.equalTo(deleteButton.snp.left).offset(-8.0)
            make.centerY.equalTo(contentView.snp.centerY)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deleteRow() {
        self.delegate?.deleteButtonTaped(at: indexPath)
    }

}
