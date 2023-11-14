//
//  ConnectionTableViewCell.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import UIKit
import CoreBluetooth

final class ConnectionTableViewCell: UITableViewCell {
    public var screenWidth = UIScreen.main.bounds.width
    public var screenHeight = UIScreen.main.bounds.height
    private var delegate: Connecttions = ConnectionViewController()
    public let bgLabel = UILabel()
    public var item: CBPeripheral!
    public let deviceName: UILabel = {
        let name = UILabel()
        name.font = UIFont(name: "Futura Bold",
                           size: 15)
//        name.textColor = .link
        name.textAlignment = .left
        return name
    }()
    public let changeDeviceNameButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"),
                        for: .normal)
        button.tintColor = .systemGreen
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: .default,
                   reuseIdentifier: "ConnectionTableViewCell")
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
         changeDeviceNameButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([deviceName.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                                    constant: 25),
                                     deviceName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                                        constant: -25),
                                     deviceName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                                         constant: 35),
                                     deviceName.trailingAnchor.constraint(equalTo: changeDeviceNameButton.leadingAnchor,
                                                                          constant: -25),
                                     
                                     changeDeviceNameButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     changeDeviceNameButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                                                      constant: -35),
                                     changeDeviceNameButton.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                                   multiplier: 0.1),
                                     changeDeviceNameButton.heightAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                                   multiplier: 0.1),
                                     
                                     bgLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     bgLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                                     bgLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                                    multiplier: 0.9),
                                     bgLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor,
                                                                     multiplier: 0.9)
        ])
        changeDeviceNameButton.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
    }
    @objc func disconnect() {
        if item.state == .connected {
//            delegate.disconnect(item: item)
//            changeDeviceNameButton.setImage(UIImage(systemName: "phone.connection"),
//                                                  for: .normal)
        }
        else {
            delegate.connect(item: item)
            changeDeviceNameButton.setImage(UIImage(systemName: "phone.connection"),
                                                  for: .normal)
        }
    }
}
