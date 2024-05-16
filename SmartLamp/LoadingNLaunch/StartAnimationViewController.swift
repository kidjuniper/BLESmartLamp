//
//  StartAnimationViewController.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import UIKit
import CoreBluetooth

final class StartAnimationViewController: UIViewController {
    private lazy var logo: UIImageView = {
        let logo = UIImageView()
        let logoImage = UIImage(systemName: "hexagon")
        logo.image = logoImage
        return logo
    }()
    
    private lazy var logolabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura Bold",
                            size: 40)
        label.textColor = .link
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSetting()
        presentMainScreen()
        
        // some UserDefaults checkings
        ["timeLeft",
        "prehetLeft",
        "timeSet",
        "cyclesSet",
        "currentCycle",
        "name"].forEach { key in
            if ((UserDefaults.standard.array(forKey: key)?.isEmpty) == nil) {
                let devices: [String : Int] = [:]
                UserDefaults.standard.set(devices, forKey: key)
            }
        }
        if ((UserDefaults.standard.array(forKey: "devices")?.isEmpty) == nil) {
            let devices: [String] = []
            UserDefaults.standard.set(devices,
                                      forKey: "devices")
        }
        
        if ((UserDefaults.standard.array(forKey: "versions")?.isEmpty) == nil) {
            let versions: [String : String] = [:]
            UserDefaults.standard.set(versions,
                                      forKey: "versions")
        }
    }
    
    func appearanceSetting() {
        // MARK: view settings
        view.backgroundColor = .systemBackground
        // MARK: subViews settings
        [logo, logolabel].forEach {
            view.addSubview($0 as UIView)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: 100),
            logo.heightAnchor.constraint(equalToConstant: 100),
            
            logolabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logolabel.topAnchor.constraint(equalTo: logo.bottomAnchor,
                                           constant: 20)
        ])
        
        logolabel.animate(newText: "Солнышко", characterDelay: 1)
    }
    
    // MARK: func to present navigation controller
    func presentMainScreen() {
        let mainScreen = CustomTabBarController()
        mainScreen.modalPresentationStyle = .fullScreen
        BLE.sharedInstance.scanCompleted { _ in
            if !BLE.sharedInstance.list.isEmpty {
            DispatchQueue.main.async {
                    self.present(mainScreen,
                                 animated: true)
                }
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.present(mainScreen,
                                 animated: true)
                }
            }
        }
    }
}

