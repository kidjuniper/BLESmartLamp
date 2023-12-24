//
//  MainViewController.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 01.11.2023.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController {
    static let shared = MainViewController()
    public var device: CBPeripheral?
    private let shapeLayer = CAShapeLayer()
    private lazy var state = 0
    private let shapeView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:
                                    "circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var deviceNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Device name"
        label.font = UIFont(name: "Futura Bold", size: 17)
        return label
    }()
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = """
        Нажмите, чтобы
        включить устройство
        """
        label.font = UIFont(name: "Futura Bold", size: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private let startTimerButton: UIButton = {
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
    
    private let onButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: "",
                                                     attributes: [.font : UIFont(name: "Futura Bold",
                                                                                 size: 15)!]),
                                  for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    private lazy var offButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: " Выключить",
                                                     attributes: [.font : UIFont(name: "Futura Bold",
                                                                                 size: 13)!,
                                                                  .foregroundColor : UIColor.systemRed]),
                                  for: .normal)
        button.setImage(UIImage(systemName: "lightswitch.off.fill"), for: .normal)
        button.tintColor = UIColor.systemRed
        return button
    }()
    
    private lazy var timer = Timer()
    
    private lazy var animationTimer = Timer()
    
    private lazy var durationTimer = 0
    
    private lazy var durationTimerAnimation = 0.0
    
    // some strange decisions for animation appearence, if you can - replace it
    private lazy var isResumed = false
    
    private lazy var firstOpen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        check()
        addObservers()
        setConstraintsActiveDevice()
        setConstraints()
        buttonAnimation()
        view.backgroundColor = .systemBackground
        deviceNameLabel.text = device?.name
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BLE.sharedInstance.notificationCenter.removeObserver(self)
        animationTimer.invalidate()
    }
    
    @objc func check() {
        // костыль для избежания рывков анимации
        BLE.sharedInstance.checkState(device!)
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
    @objc func onButtonFunc() {
        BLE.sharedInstance.setOnLamp(peripheral: device!,
                                     complition: { _ in
            self.timerLabel.layer.opacity = 1
            self.setConstraintsActiveDevice()
            self.onButton.removeTarget(self,
                                       action: #selector(self.onButtonFunc),
                                       for: .touchUpInside)
        })
    }
    
    // MARK: state updated functions
    @objc func stillOff() {
        state = 0
        timer.invalidate()
        startTimerButton.removeTarget(self,
                                      action: #selector(resumeLamp),
                                      for: .touchUpInside)
        startTimerButton.addTarget(self,
                                   action: #selector(startButtonTapped),
                                   for: .touchUpInside)
        startTimerButton.setAttributedTitle(NSAttributedString(string: "Таймер",
                                                               attributes: [.font : UIFont(name: "Futura Bold",
                                                                                           size: 15)!]),
                                            for: .normal)
        shapeLayer.removeFromSuperlayer()
        offButton.removeFromSuperview()
        onButton.addTarget(self,
                           action: #selector(onButtonFunc),
                           for: .touchUpInside)
        self.timerLabel.text = """
        Нажмите, чтобы
        включить устройство
        """
        buttonAnimation()
    }
    
    @objc func justOn() {
        state = 1
        firstOpen = true
        startTimerButton.addTarget(self,
                                   action: #selector(startButtonTapped),
                                   for: .touchUpInside)
        self.timerLabel.text = """
        Устройство включено
        """
        self.timerLabel.layer.opacity = 1
        
    }
    @objc func preheatTimer() {
        if state == 2 {
            isResumed = true
        }
        state = 2
        onButton.removeTarget(self,
                              action: #selector(self.onButtonFunc),
                              for: .touchUpInside)
        startTimerButton.removeTarget(self,
                                      action: #selector(self.startButtonTapped),
                                      for: .touchUpInside)
        setConstraintsActiveDevice()
        startTimerButton.addTarget(self,
                                   action: #selector(turnOff),
                                   for: .touchUpInside)
        timer.invalidate() // if we've already start timer
        let data = UserDefaults.standard.dictionary(forKey: "prehetLeft") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        durationTimer = data[deviceName] ?? 0
        basicAnimationPreheat()
        animationCircularPreheat()
        timerFuncPreheat()
        timer = Timer.scheduledTimer (timeInterval: 1,
                                      target: self,
                                      selector: #selector (self.timerFuncPreheat),
                                      userInfo: nil,
                                      repeats: true)
    }
    @objc func startTimer() {
        setConstraintsActiveDevice()
        onButton.removeTarget(self,
                              action: #selector(self.onButtonFunc),
                              for: .touchUpInside)
        startTimerButton.removeTarget(self,
                                      action: #selector(startButtonTapped),
                                      for: .touchUpInside)
        timer.invalidate() // if we've already start timer
        if durationTimer == 0 {
            isResumed = false
        }
        if state == 3 {
            isResumed = true
        }
        state = 3
        let data = UserDefaults.standard.dictionary(forKey: "timeLeft") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        durationTimer = data[deviceName] ?? 0
        if !isResumed {
            animationCircular()
            self.basicAnimation()
        }
        timerFunc()
        isResumed = false
        timer = Timer.scheduledTimer (timeInterval: 1,
                                      target: self,
                                      selector: #selector (self.timerFunc),
                                      userInfo: nil,
                                      repeats: true)
        startTimerButton.isHidden = false
        self.startTimerButton.setAttributedTitle(NSAttributedString(string: "Пауза",
                                                                    attributes: [.font : UIFont(name: "Futura Bold",
                                                                                                size: 15)!]),
                                                 for: .normal)
        startTimerButton.tintColor = .white
        startTimerButton.removeTarget(self,
                                      action: #selector(self.resumeLamp),
                                      for: .touchUpInside)
        startTimerButton.removeTarget(self,
                                      action: #selector(self.startButtonTapped),
                                      for: .touchUpInside)
        startTimerButton.addTarget(self,
                                   action: #selector(self.pauseLamp),
                                   for: .touchUpInside)
        
    }
    @objc func pause() {
        state = 4
        
        onButton.removeTarget(self,
                              action: #selector(self.onButtonFunc),
                              for: .touchUpInside)
        startTimerButton.removeTarget(self,
                                      action: #selector(self.startButtonTapped),
                                      for: .touchUpInside)
        setConstraintsActiveDevice()
        isResumed = true
        timerLabel.text = "Пауза"
        timer.invalidate()
        startTimerButton.setAttributedTitle(NSAttributedString(string: "Пуск",
                                                               attributes: [.font : UIFont(name: "Futura Bold",
                                                                                           size: 15)!]),
                                            for: .normal)
        startTimerButton.addTarget(self,
                                   action: #selector(resumeLamp),
                                   for: .touchUpInside)
    }
    
    
    // MARK: the lamp commands
    @objc func resumeLamp() {
        BLE.sharedInstance.resumeLamp(peripheral: device!) { succes in
            if !succes {
                print("тут будет алерт resumeLamp")
            }
            else {
                self.shapeLayer.resumeAnimation()
                self.startTimerButton.setAttributedTitle(NSAttributedString(string: "Пауза",
                                                                            attributes: [.font : UIFont(name: "Futura Bold",
                                                                                                        size: 15)!]),
                                                         for: .normal)
                self.startTimerButton.removeTarget(self,
                                                   action: #selector(self.resumeLamp),
                                                   for: .touchUpInside)
                self.startTimerButton.addTarget(self,
                                                action: #selector(self.pauseLamp),
                                                for: .touchUpInside)
            }
        }
    }
    @objc func pauseLamp() {
        BLE.sharedInstance.pauseLamp(peripheral: device!) { succes in
            if !succes {
                print("тут будет алерт pauseLamp")
            }
            else {
                self.shapeLayer.pauseAnimation()
                self.startTimerButton.setAttributedTitle(NSAttributedString(string: "Пуск",
                                                                            attributes: [.font : UIFont(name: "Futura Bold",
                                                                                                        size: 15)!]),
                                                         for: .normal)
                self.startTimerButton.removeTarget(self,
                                                   action: #selector(self.pauseLamp),
                                                   for: .touchUpInside)
                self.startTimerButton.addTarget(self,
                                                action: #selector(self.resumeLamp),
                                                for: .touchUpInside)
            }
        }
    }
    
    // MARK: other funcs
    @objc func startButtonTapped() {
        let mainScreen = TimerPopUpViewController()
        mainScreen.device = device
        mainScreen.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(mainScreen,
                         animated: false)
        }
    }
    @objc func timerFunc() {
        let data = UserDefaults.standard.dictionary(forKey: "cyclesSet") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        let cycles = Double(data[deviceName] ?? 0)
        let data2 = UserDefaults.standard.dictionary(forKey: "currentCycle") as! [String : Int]
        let cc = Double(data2[deviceName] ?? 0)
        timerLabel.text = """
        Цикл \(Int(cc))/\(Int(cycles))
        Осталось \(Int(durationTimer/60)) : \(durationTimer%60 > 9 ? "\(durationTimer%60)" : "0\(durationTimer%60)")
        """
        if durationTimer > 0 {
            durationTimer -= 1
        }
        else {
            isResumed = false
            timer.invalidate()
            shapeView.layer.sublayers?.first?.removeFromSuperlayer()
        }
    }
    @objc func timerFuncPreheat() {
        timerLabel.text = """
Идет прогрев устройства
Осталось \(Int(durationTimer/60)) : \(durationTimer%60 > 9 ? "\(durationTimer%60)" : "0\(durationTimer%60)")
"""
        if durationTimer > 0 {
            durationTimer -= 1
        }
        else {
            timer.invalidate()
            shapeView.layer.sublayers?.first?.removeFromSuperlayer()
        }
        startTimerButton.isHidden = true
    }
    @objc func turnOff() {
        if state != 2 {
            let alert = UIAlertController(title: "Отключить лампу?",
                                          message: "",
                                          preferredStyle: .alert)
            
            let offAction = UIAlertAction(title: "Да",
                                          style: .destructive) { _ in
                self.off()
                self.dismiss(animated: true)
            }
            let okAction = UIAlertAction(title: "Отмена",
                                         style: .default)
            alert.addAction(offAction)
            alert.addAction(okAction)
            self.present(alert,
                         animated: true)
        }
        else {
            let alert = UIAlertController(title: "Предупреждение",
                                          message: "В настоящий момент происходит нагрев и стабилизация лампы. Её отключение в течение этого периода может привести к нарушению работы устройства",
                                          preferredStyle: .alert)
            let offAction = UIAlertAction(title: "Все равно отключить",
                                          style: .destructive) { _ in
                self.off()
            }
            let okAction = UIAlertAction(title: "Отмена",
                                         style: .default)
            alert.addAction(offAction)
            alert.addAction(okAction)
            self.present(alert,
                         animated: true)
        }
    }
    func off() {
        if !BLE.sharedInstance.setOffLamp(peripheral: device!) {
            let alert1 = UIAlertController(title: "Ошибка",
                                           message: "Не удалось выключить устройство, проверьте соединение",
                                           preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .cancel)
            alert1.addAction(okAction)
            self.present(alert1,
                         animated: true)
        }
    }
}

extension MainViewController {
    func setConstraintsActiveDevice() {
        offButton.addTarget(self,
                            action: #selector(turnOff),
                            for: .touchUpInside)
        [startTimerButton, onButton, offButton].forEach { item in
            view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            onButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            onButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            onButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                            multiplier: 0.6),
            onButton.heightAnchor.constraint(equalTo: view.widthAnchor,
                                             multiplier: 0.6),
            
            startTimerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startTimerButton.topAnchor.constraint(equalTo: onButton.bottomAnchor,
                                                  constant: 80),
            startTimerButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                    multiplier: 0.85),
            startTimerButton.heightAnchor.constraint(equalTo: view.widthAnchor,
                                                     multiplier: 0.15),
            
            offButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            offButton.topAnchor.constraint(equalTo: startTimerButton.bottomAnchor,
                                           constant: 10),
            offButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                             multiplier: 0.8),
            offButton.heightAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: 0.15)
        ])
    }
    func setConstraints() {
        let de = UILabel()
        de.backgroundColor = .black
        de.layer.cornerRadius = 4
        de.clipsToBounds = true
        
        [onButton, deviceNameLabel, timerLabel, shapeView, de].forEach { item in
            view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            de.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            de.widthAnchor.constraint(equalTo: view.widthAnchor,
                                      multiplier: 0.2),
            de.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            de.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.02),
            
            onButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            onButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            onButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                            multiplier: 0.6),
            onButton.heightAnchor.constraint(equalTo: view.widthAnchor,
                                             multiplier: 0.6),
            
            shapeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shapeView.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                               constant: -50),
            shapeView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                             multiplier: 0.8),
            shapeView.heightAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: 0.8),
            
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                                constant: -50),
            timerLabel.widthAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: 0.6),
            
            deviceNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceNameLabel.heightAnchor.constraint(equalTo: view.widthAnchor,
                                                    multiplier: 0.15),
            deviceNameLabel.topAnchor.constraint(equalTo: de.bottomAnchor,
                                                 constant: 20)
        ])
    }
    func buttonAnimation() {
        if !animationTimer.isValid {
            animate()
            animationTimer = Timer.scheduledTimer(timeInterval: 0.7,
                                                  target: self,
                                                  selector: #selector(self.animate),
                                                  userInfo: nil,
                                                  repeats: true)
            animationTimer.fire()
        }
        
    }
    @objc func animate() {
        UILabel.animate(withDuration: 0.7) {
            self.timerLabel.layer.opacity = self.timerLabel.layer.opacity == 1.0 ? 0.2 : 1.0
        }
    }
    @objc func lost() {
        let alert = UIAlertController(title: "Соединение потеряно",
                                      message: "Проверьте устройство и попробуйте переподключиться",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ок",
                                   style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        self.present(alert,
                     animated: true)
    }
    
    func animationCircularPreheat() {
        let center = CGPoint(x: shapeView.frame.width / 2,
                             y: shapeView.frame.height / 2)
        let endAngle = (-CGFloat.pi / 2)
        
        let data = UserDefaults.standard.dictionary(forKey: "prehetLeft") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        durationTimerAnimation = Double(data[deviceName] ?? 0)
        
        shapeLayer.removeFromSuperlayer()
        
        let startAngle = 2 * CGFloat.pi * CGFloat(1 - durationTimerAnimation/60) + endAngle
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: (shapeView.frame.width - shapeView.frame.width * 0.101) / 2,
                                        startAngle: endAngle,
                                        endAngle: startAngle,
                                        clockwise: false)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineWidth = shapeView.frame.width * 0.101
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 1
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeColor = UIColor.systemRed.cgColor
        shapeView.layer.addSublayer(shapeLayer)
    }
    
    func animationCircular() {
        let center = CGPoint(x: shapeView.frame.width / 2,
                             y: shapeView.frame.height / 2)
        let endAngle = (-CGFloat.pi / 2)
        
        let data = UserDefaults.standard.dictionary(forKey: "timeLeft") as! [String : Int]
        let deviceName = "\(device!.identifier)"
        durationTimerAnimation = Double(data[deviceName] ?? 0)
        
        let data2 = UserDefaults.standard.dictionary(forKey: "timeSet") as! [String : Int]
        let circleTime = Double(data2[deviceName] ?? 0)
        if durationTimerAnimation != 0 {
            let startAngle = 2 * CGFloat.pi * CGFloat(1 - (1 / circleTime + 1) - (durationTimerAnimation)/circleTime) + endAngle
            let circularPath = UIBezierPath(arcCenter: center,
                                            radius: (shapeView.frame.width - shapeView.frame.width * 0.101) / 2,
                                            startAngle: endAngle,
                                            endAngle: startAngle,
                                            clockwise: false)
            shapeLayer.path = circularPath.cgPath
            shapeLayer.lineWidth = shapeView.frame.width * 0.101
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeEnd = 1
            shapeLayer.lineCap = CAShapeLayerLineCap.round
            shapeLayer.strokeColor = UIColor.link.cgColor
            shapeView.layer.addSublayer(shapeLayer)
        }
    }
    func basicAnimation() {
        if durationTimerAnimation >= 1 {
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.toValue = 0
            basicAnimation.duration = CFTimeInterval(durationTimer)
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            shapeLayer.add(basicAnimation, forKey: "basicAnimation")
        }
    }
    func basicAnimationPreheat() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 0
        basicAnimation.duration = CFTimeInterval(durationTimer)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
    }
}

extension MainViewController {
    func addObservers() {
        let deviceName = "\(device!.identifier)"
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(preheatTimer),
                                                          name: NSNotification.Name(rawValue: "preheat\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(startTimer),
                                                          name: NSNotification.Name(rawValue: "active\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(pause),
                                                          name: NSNotification.Name(rawValue: "pause\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(stillOff),
                                                          name: NSNotification.Name(rawValue: "settedOff\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(justOn),
                                                          name: NSNotification.Name(rawValue: "justOn\(deviceName)"),
                                                          object: nil)
        BLE.sharedInstance.notificationCenter.addObserver(self,
                                                          selector: #selector(lost),
                                                          name: NSNotification.Name(rawValue: "lost\(deviceName)"),
                                                          object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(check),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
}
