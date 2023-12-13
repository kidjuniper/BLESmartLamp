//
//  ConnectionViewController.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import UIKit
import CoreBluetooth

class ConnectionViewController: UIViewController {
    public var possibleDevices: [CBPeripheral] = []
    public var connectedDevices: [CBPeripheral] = []
    private var timer = Timer()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConnectionTableViewCell.self,
                           forCellReuseIdentifier: "ConnectionTableViewCell")
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = true
        return tableView
    }()
    public let noDevices: UILabel = {
        let label = UILabel()
        label.text = "Нет доступных устройств"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // updating possible devices list every 5 seconds
        timer = Timer.scheduledTimer(timeInterval: 5,
                                     target: self,
                                     selector: #selector(reloadData),
                                     userInfo: nil,
                                     repeats: true)
        possibleDevices = BLE.sharedInstance.list.createArray() as! [CBPeripheral]
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData),
                                               name: NSNotification.Name(rawValue: "load"),
                                               object: nil)
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
                                     noDevices.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                                    ])
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkTimer),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    @objc func checkTimer() {
        if !timer.isValid {
            timer.fire()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        possibleDevices = BLE.sharedInstance.list.createArray() as! [CBPeripheral]
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData),
                                               name: NSNotification.Name(rawValue: "load"),
                                               object: nil)
    }
    @objc func reloadData(notification: NSNotification) {
        possibleDevices = BLE.sharedInstance.list.createArray() as! [CBPeripheral]
        tableView.reloadData()
        if BLE.sharedInstance.manager.state == .poweredOn {
            BLE.sharedInstance.scanCompleted { _ in
                self.possibleDevices = BLE.sharedInstance.list.createArray() as! [CBPeripheral]
                self.tableView.reloadData()
            }
        }
        else {
            if BLE.sharedInstance.manager.state == .poweredOff {
                let alert = UIAlertController(title: "Кажется, bluetooth отключен!",
                                              message: "Проверьте, включен ли bluetooth на вашем смартфоне",
                                              preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ок",
                                           style: .default) { _ in
       
                }
                alert.addAction(action)
                self.present(alert,
                             animated: true)
            }
            else {
                let alert = UIAlertController(title: "Необходимо разрешение!",
                                              message: "Разрешите приложению использовать bluetooth. Без этого управлять девайсами не получится",
                                              preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ок",
                                           style: .default) { _ in
         
                }
                alert.addAction(action)
                self.present(alert,
                             animated: true)
            }
        }
    }
}

extension ConnectionViewController: Connecttions {
    func disconnect(item: CBPeripheral) {
        BLE.sharedInstance.disconnect(item: item)
    }
    func connect(item: CBPeripheral) {
        BLE.sharedInstance.connect(item: item)
    }
    func reload() {
        tableView.reloadData()
    }
}

