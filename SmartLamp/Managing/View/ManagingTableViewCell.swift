//
//  ManagingTableViewCell.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import UIKit
import CoreBluetooth

final class ManagingTableViewCell: UITableViewCell {
    public var screenWidth = UIScreen.main.bounds.width
    public var screenHeight = UIScreen.main.bounds.height
    public let bgLabel = UILabel()
    public var item: CBPeripheral!
    public var forgetFunc: (CBPeripheral) -> Void
    private var delegate: Forget = ManagingViewController()
    public var delegateForRename: Rename?
    public var delegateForInfo: Info?
    public let deviceName: UILabel = {
        let name = UILabel()
        name.font = UIFont(name: "Futura Bold",
                           size: 15)
        name.textAlignment = .left
        return name
    }()
    public let forgetDeviceButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"),
                        for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    public let changeNameButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"),
                        for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    public let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"),
                        for: .normal)
        button.tintColor = .systemGreen
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        func fakeFunction(_ data: CBPeripheral) {
        }
        forgetFunc = fakeFunction
        super.init(style: .default,
                   reuseIdentifier: "ManagingTableViewCell")
        cellSettings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool,
                              animated: Bool) {
        super.setSelected(selected,
                          animated: animated)
    }
    
    // MARK: cell appearance
    func cellSettings() {
        selectionStyle = .none
        let frame = !((screenHeight / screenWidth) > 2)
        if frame {
            screenHeight = screenHeight * 1.08
            screenWidth = screenWidth * 0.97
        }
        
        bgLabel.backgroundColor = .systemGray5
        bgLabel.layer.cornerRadius = screenWidth / 20
        bgLabel.clipsToBounds = true
        
        [bgLabel,
         deviceName,
         changeNameButton,
         forgetDeviceButton,
         infoButton
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([deviceName.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                                    constant: 25),
                                     deviceName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                                        constant: -25),
                                     deviceName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                                         constant: 35),
                                     deviceName.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor,
                                                                          constant: -25),
                                     
                                     forgetDeviceButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     forgetDeviceButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                                                      constant: -35),
                                     forgetDeviceButton.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                                   multiplier: 0.1),
                                     forgetDeviceButton.heightAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                                   multiplier: 0.1),
                                     
                                     changeNameButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     changeNameButton.trailingAnchor.constraint(equalTo: forgetDeviceButton.trailingAnchor,
                                                                                      constant: -35),
                                     changeNameButton.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                                   multiplier: 0.1),
                                     changeNameButton.heightAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                                   multiplier: 0.1),
                                     
                                     infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     infoButton.trailingAnchor.constraint(equalTo: changeNameButton.trailingAnchor,
                                                                                      constant: -35),
                                     infoButton.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                                   multiplier: 0.1),
                                     infoButton.heightAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                                   multiplier: 0.1),
                                     
                                     bgLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     bgLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                                     bgLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                    multiplier: 0.9),
                                     bgLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor,
                                                                     multiplier: 0.9)
        ])
        
        forgetDeviceButton.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        changeNameButton.addTarget(self, action: #selector(rename), for: .touchUpInside)
    }
    @objc func disconnect() {
        delegate.forget(item: item!)
    }
    
    @objc func rename() {
        delegateForRename?.rename(item: item!)
    }
    
    @objc func showInfo() {
        delegateForInfo?.info(item: item!)
    }
}
