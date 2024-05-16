//
//  InfoTableViewCell.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 15.05.2024.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 5
        return stack
    }()
    
    public let topLabel: UILabel = {
        let name = UILabel()
        name.font = UIFont(name: "Futura Bold",
                           size: 15)
        name.textAlignment = .left
        name.textColor = .black
        return name
    }()
    
    public let bottomLabel: UILabel = {
        let name = UILabel()
        name.font = UIFont(name: "Futura Bold",
                           size: 13)
        name.textAlignment = .left
        name.textColor = .darkGray
        return name
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: .default,
                   reuseIdentifier: "InfoTableViewCell")
        setUp(top: "", bottom: "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(top: String,
               bottom: String) {
        mainStack.addArrangedSubviews(topLabel,
                                      bottomLabel)
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topLabel.text = top
        bottomLabel.text = bottom
    }

}
