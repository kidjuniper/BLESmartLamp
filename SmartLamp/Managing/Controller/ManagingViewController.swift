//
//  ManagingViewController.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import UIKit
import CoreBluetooth

class ManagingViewController: UIViewController {
    public var connectedDevices: Set<CBPeripheral> = []
    var connectedDevicesArray: [CBPeripheral] = []
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ManagingTableViewCell.self,
                           forCellReuseIdentifier: "ManagingTableViewCell")
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = true
        return tableView
    }()
    
    public let noDevices: UILabel = {
        let label = UILabel()
        label.text = "Нет подключенных устройств"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(reloadDevices),
                                               name: NSNotification.Name(rawValue: "load"),
                                               object: nil)
        connectedDevicesArray = BLE.sharedInstance.connectedDevicesArray
        [tableView,
         noDevices].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
                                     tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
                                    
                                     noDevices.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     noDevices.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // перепроверяем подключенные устройства
    @objc func reloadDevices() {
        BLE.sharedInstance.updateConnected { data in
            self.connectedDevicesArray = data
            self.tableView.reloadData()
        }
    }
}

extension ManagingViewController: Forget {
    func forget(item: CBPeripheral) {
        BLE.sharedInstance.forget(item: item)
    }
}


