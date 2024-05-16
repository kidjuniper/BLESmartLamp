//
//  MainViewController.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 01.11.2023.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController {
    
    public var device: CBPeripheral? // selected device
    lazy var state = 0 // current device state (0...4)
    
    lazy var deviceNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Device name"
        label.font = UIFont(name: "Futura Bold",
                            size: 17)
        return label
    }()
    
    let shapeLayer = CAShapeLayer() // layer for circle animation
    let shapeView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:
                                    "circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var centralLabel: UILabel = {
        let label = UILabel()
        label.text = "Устройство готово"
        label.font = UIFont(name: "Futura Bold",
                            size: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    // включение с таймером
    let startTimerButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = .white
        button.backgroundColor = .link
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.tintColor = .white
        button.setAttributedTitle(NSAttributedString(string: "Таймер",
                                                     attributes: [.font : UIFont(name: "Futura Bold",
                                                                                 size: 15)!]),
                                  for: .normal)
        return button
    }()
    // включение/выключение без таймера
    lazy var onOffButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: " Включить",
                                                     attributes: [.font : UIFont(name: "Futura Bold",
                                                                                 size: 15)!,
                                                                  .foregroundColor : UIColor.systemRed]),
                                  for: .normal)
        button.setImage(UIImage(systemName: "lightswitch.off.fill"), for: .normal)
        button.tintColor = UIColor.systemRed
        return button
    }()
    
    lazy var timer = Timer()
    lazy var animationTimer = Timer()
    lazy var durationTimer = 0
    lazy var durationTimerAnimation = 0.0
    
    lazy var isResumed = false
    lazy var firstOpen = true
    
    // MARK: - overriding view functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        check()
        setStartedAppearance()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BLE.sharedInstance.notificationCenter.removeObserver(self)
        animationTimer.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if state == 4 && firstOpen {
            animationCircular()
            firstOpen = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstOpen = false
        if state == 4 {
            animationCircular()
        }
    }
}




