//
//  ChangeNamePopUp.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 30.03.2024.
//

import Foundation
import UIKit
import CoreBluetooth

final class PopUp: UIView {
    public var centerConstraint: NSLayoutConstraint?
    
    var device: CBPeripheral? {
        didSet {
            let itemsAliasDict = UserDefaultsManager().fetchObject(type: [String : String].self,
                                                                   for: .names) ?? [:]
            
            if let a = itemsAliasDict[(device?.identifier.uuidString) ?? "efsdfsdfdsfwer"] {
                popUpTextField.text = a
            }
            else {
                popUpTextField.text = device?.name
            }
        }
    }
    
    let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .equalSpacing
        return stack
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Переименовать:"
        label.textAlignment = .center
        label.font = UIFont(name: "Futura Bold",
                            size: 17)
        return label
    }()
    
    let popUpTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Futura",
                                size: 15)
        textField.layer.cornerRadius = 5
        textField.textColor = .black
        textField.clipsToBounds = true
        let paddingView = UIView(frame: CGRect(x: 0,
                                               y: 0,
                                               width: 7.5,
                                               height: 5))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .lightGray
        return textField
    }()
    
    let applyButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = .white
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.tintColor = .white
        button.setAttributedTitle(NSAttributedString(string: "Подтвердить",
                                                     attributes: [.font : UIFont(name: "Futura Bold",
                                                                                 size: 15)!]), for: .normal)
        return button
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = .white
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.tintColor = .white
        button.setAttributedTitle(NSAttributedString(string: "Отмена",
                                                     attributes: [.font : UIFont(name: "Futura Bold",
                                                                                 size: 15)!]), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        self.addSubview(verticalStack)
        self.backgroundColor = .systemGray5
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        if let sv = superview {
            centerConstraint = self.centerXAnchor.constraint(equalTo: sv.centerXAnchor)
            centerConstraint?.isActive = true
        }
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([verticalStack.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                                            constant: 20),
                                     verticalStack.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                                             constant: -20),
                                     verticalStack.topAnchor.constraint(equalTo: self.topAnchor,
                                                                        constant: 20),
                                     verticalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                                           constant: -20)])
        
        
        verticalStack.addArrangedSubviews(label,
                                          popUpTextField,
                                          horizontalStack)
        popUpTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        horizontalStack.addArrangedSubviews(applyButton,
                                            closeButton)
        
        applyButton.addTarget(self,
                              action: #selector(saveNewAlias),
                              for: .touchUpInside)
        
        closeButton.addTarget(self,
                              action: #selector(close), 
                              for: .touchUpInside)
    }
    
    @objc func close() {
        superview?.removePopUP()
    }
    
    @objc func saveNewAlias() {
        var itemsAliasDict = UserDefaultsManager().fetchObject(type: [String : String].self,
                                                               for: .names) ?? [:]
        if (popUpTextField.text?.split(separator: " ").count != 0) {
            var counter = 0
            for i in itemsAliasDict {
                if i.value == popUpTextField.text ?? "" && i.key != device?.identifier.uuidString {
                    counter += 1
                }
            }
            
            if counter > 0 {
                
                itemsAliasDict.updateValue("\(String(describing: popUpTextField.text ?? "")) (\(counter - 1))",
                                           forKey: device?.identifier.uuidString ?? "")
                UserDefaultsManager().saveObject(value: itemsAliasDict,
                                                 for: .names)
            }
            
            else {
                itemsAliasDict.updateValue(popUpTextField.text ?? "",
                                           forKey: device?.identifier.uuidString ?? "")
                UserDefaultsManager().saveObject(value: itemsAliasDict,
                                                 for: .names)     
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"),
                                            object: nil)
            superview?.removePopUP()
        }
        else {
            popUpTextField.attributedPlaceholder = NSAttributedString(string: "Имя девайса не может быть пустым!",
                                                                      attributes: [NSAttributedString.Key.strokeColor : UIColor.white.cgColor])
        }
    }
}
