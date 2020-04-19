//
//  LocationCell.swift
//  UberClone
//
//  Created by Maksim on 19/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

let reuseIdentifierLocationCell = "LocationCell"


class LocationCell: UITableViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "29 Berry St"
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "Liberty Living Plc, 29 Berry St, Manchester, M1 2AR"
        return label
    }()
    
    private let indicatorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "star")!)
        imageView.anchor(width: 30, height: 30)
        return imageView
    }()
    
    
    
    
    //MARK: - Initialisation
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(indicatorImageView)
        indicatorImageView.anchor(left: leftAnchor, paddingLeft: 12)
        indicatorImageView.centerY(inView: self)
        
        
        let stack = UIStackView(arrangedSubviews: [titleLabel,
                                                   addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self)
        stack.anchor(left: indicatorImageView.rightAnchor, paddingLeft: 12)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  

}
