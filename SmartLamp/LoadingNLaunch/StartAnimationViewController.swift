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
        if ((UserDefaults.standard.array(forKey: "timeLeft")?.isEmpty) == nil) {
            let devices: [String : Int] = [:]
            UserDefaults.standard.set(devices, forKey: "timeLeft")
        }
        if ((UserDefaults.standard.array(forKey: "prehetLeft")?.isEmpty) == nil) {
            let devices: [String : Int] = [:]
            UserDefaults.standard.set(devices, forKey: "prehetLeft")
        }
        if ((UserDefaults.standard.array(forKey: "timeSet")?.isEmpty) == nil) {
            let devices: [String:Int] = [:]
            UserDefaults.standard.set(devices, forKey: "timeSet")
        }
        if ((UserDefaults.standard.array(forKey: "cyclesSet")?.isEmpty) == nil) {
            let devices: [String:Int] = [:]
            UserDefaults.standard.set(devices, forKey: "cyclesSet")
        }
        if ((UserDefaults.standard.array(forKey: "currentCycle")?.isEmpty) == nil) {
            let devices: [String:Int] = [:]
            UserDefaults.standard.set(devices, forKey: "currentCycle")
        }
        if ((UserDefaults.standard.array(forKey: "name")?.isEmpty) == nil) {
            let devices: [String:String] = [:]
            UserDefaults.standard.set(devices, forKey: "name")
        }
        
        if ((UserDefaults.standard.array(forKey: "devices")?.isEmpty) == nil) {
            let devices: [String] = []
            UserDefaults.standard.set(devices,
                                      forKey: "devices")
        }
        else {
            print(UserDefaults.standard.array(forKey: "devices")!)
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
            DispatchQueue.main.async {
                self.present(mainScreen,
                             animated: true)
            }
        }
    }
}

