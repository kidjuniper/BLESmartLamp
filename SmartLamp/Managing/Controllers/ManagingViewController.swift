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
    
    var popUp: PopUp?
    
    var infoData: [String] = .init(repeating: "", count: 3)
    
    let infoDataKeys = ["Название устройства", "Identifier устройства", "Версия прошивки"]
    
    // MARK: points bottom sheet view constraints
    public var centerYConstraint: NSLayoutConstraint?
    public var heightConstraint: NSLayoutConstraint?
    
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
    
    public lazy var bottomSheetView: UIView = {
        let bottomSheetView = UIView(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: 0,
                                                   height: 0))
        bottomSheetView.layer.cornerRadius = 25
        bottomSheetView.backgroundColor = .white
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetView.layer.masksToBounds = false
        bottomSheetView.layer.shadowColor = UIColor.black.cgColor
        bottomSheetView.layer.shadowRadius = 10
        bottomSheetView.layer.shadowOpacity = 0.5
        return bottomSheetView
    }()
    
    public let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Информация:"
        label.font = UIFont(name: "Futura Bold",
                             size: 15)
        label.textColor = .link
        return label
    }()

    public lazy var infoTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(InfoTableViewCell.self,
                           forCellReuseIdentifier: "InfoTableViewCell")
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.isUserInteractionEnabled = false
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
         noDevices,
         bottomSheetView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        centerYConstraint = bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                    constant: 360)
        
        heightConstraint = bottomSheetView.heightAnchor.constraint(equalToConstant: 350)
        
        NSLayoutConstraint.activate([tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
                                     tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
                                    
                                     noDevices.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     noDevices.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                    
                                     bottomSheetView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
                                     bottomSheetView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                    
                                    centerYConstraint!,
                                    heightConstraint!])
        
        setupPanGesture(for: bottomSheetView)
        
        let de = UILabel()
        de.backgroundColor = .black
        de.layer.cornerRadius = 4
        de.clipsToBounds = true
        
        bottomSheetView.addSubview(de)
        de.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            de.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            de.widthAnchor.constraint(equalTo: bottomSheetView.widthAnchor,
                                      multiplier: 0.2),
            de.topAnchor.constraint(equalTo: bottomSheetView.topAnchor,
                                    constant: 20),
            de.heightAnchor.constraint(equalTo: bottomSheetView.widthAnchor,
                                       multiplier: 0.02)
        ])
        
        bottomSheetView.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 20).isActive = true
        infoLabel.topAnchor.constraint(equalTo: de.topAnchor, constant: 20).isActive = true
        
        bottomSheetView.addSubview(infoTableView)
        infoTableView.translatesAutoresizingMaskIntoConstraints = false
        infoTableView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20).isActive = true
        infoTableView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 20).isActive = true
        infoTableView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -20).isActive = true
        infoTableView.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor, constant: -20).isActive = true
        
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

extension ManagingViewController: Rename {
    func rename(item: CBPeripheral) {
        popUp = PopUp()
        popUp?.device = item
        popUp?.popUpTextField.delegate = self
        view.presentPopUp(popUp: popUp!)
    }
}

extension ManagingViewController: Info {
    func info(item: CBPeripheral) {
        let itemsAliasDict = UserDefaultsManager().fetchObject(type: [String : String].self,
                                                               for: .names) ?? [:]
        var name = ""
        if let a = itemsAliasDict[(item.identifier.uuidString)] {
            name = a
        }
        else {
            name = item.name ?? "н/д"
        }
        
        var data = UserDefaults.standard.dictionary(forKey: "versions") as! [String : String]
        let version = data["\(item.identifier)"] ?? "н/д"
        
        
        infoData = [name, "\(item.identifier)", version]
        infoTableView.reloadData()
        UIView.animate(withDuration: 0.35) {
            self.centerYConstraint!.constant = 0
            self.heightConstraint!.constant = 350
            self.view.layoutIfNeeded()
        }
    }
}

