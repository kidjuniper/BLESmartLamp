//
//  TimerPopUpViewController.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 04.11.2023.
//

import UIKit
import CoreBluetooth

class TimerPopUpViewController: UIViewController {
    public var device: CBPeripheral?
    private lazy var popUpView: UIView = {
        let popUp = UIView(frame: CGRect(x: 0,
                                         y: 0,
                                         width: 0,
                                         height: 0))
        popUp.layer.cornerRadius = 25
        popUp.backgroundColor =
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.black
            default:
                return UIColor.white
            }
        }
        popUp.translatesAutoresizingMaskIntoConstraints = false
        return popUp
    }()
    private lazy var downView: UIView = {
        let downView = UIView(frame: CGRect(x: 0,
                                            y: 0,
                                            width: view.bounds.width * 1.1,
                                            height: view.bounds.height * 1.1))
        downView.backgroundColor = .clear
        return downView
    }()
    private lazy var secondsPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    private lazy var minutesPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    private lazy var cyclesPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = .white
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.tintColor = .white
        button.setAttributedTitle(NSAttributedString(string: "Установить",
                                                     attributes: [.font : UIFont(name: "Futura Bold",
                                                                                 size: 15)!]),
                                  for: .normal)
        return button
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Параметры процедур"
        label.font = UIFont(name: "Futura Bold",
                            size: 15)
        return label
    }()
    private lazy var minutesLabel: UILabel = {
        let label = UILabel()
        label.text = "Минуты"
        label.font = UIFont(name: "Futura Bold",
                            size: 12)
        return label
    }()
    private lazy var secondsLabel: UILabel = {
        let label = UILabel()
        label.text = "Секунды"
        label.font = UIFont(name: "Futura Bold",
                            size: 12)
        return label
    }()
    private lazy var cyclesLabel: UILabel = {
        let label = UILabel()
        label.text = """
Количество
процедур
"""
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "Futura Bold",
                            size: 12)
        return label
    }()
    public var centerConstraint: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismis2))
        backButton.addTarget(self, action: #selector(dismis),
                             for: .touchUpInside)
        centerConstraint = popUpView.centerXAnchor.constraint(equalTo: view.centerXAnchor,
                                                              constant: UIScreen.main.bounds.width / -1)
        downView.addGestureRecognizer(tapGesture)
        secondsPicker.selectRow(4980,
                                inComponent: 0,
                                animated: false)
        minutesPicker.selectRow(4980,
                                inComponent: 0,
                                animated: false)
        view.addSubview(downView)
        [
            popUpView,
            secondsPicker,
            minutesPicker,
            cyclesPicker,
            backButton,
            titleLabel,
            minutesLabel,
            secondsLabel,
            cyclesLabel].forEach { views in
                view.addSubview(views)
                views.translatesAutoresizingMaskIntoConstraints = false
            }
        NSLayoutConstraint.activate([
            popUpView.topAnchor.constraint(equalTo: view.centerYAnchor,
                                           constant: -70),
            self.centerConstraint!,
            popUpView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.85),
            popUpView.heightAnchor.constraint(equalToConstant: 410),
            
            titleLabel.topAnchor.constraint(equalTo: popUpView.topAnchor,
                                            constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor),
            
            minutesLabel.centerXAnchor.constraint(equalTo: minutesPicker.centerXAnchor),
            minutesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                              constant: 25),
            
            secondsLabel.centerXAnchor.constraint(equalTo: secondsPicker.centerXAnchor),
            secondsLabel.topAnchor.constraint(equalTo: minutesLabel.topAnchor),
            
            cyclesLabel.centerYAnchor.constraint(equalTo: secondsLabel.centerYAnchor),
            cyclesLabel.centerXAnchor.constraint(equalTo: cyclesPicker.centerXAnchor),
            
            minutesPicker.centerYAnchor.constraint(equalTo: popUpView.centerYAnchor,
                                                   constant: -10),
            minutesPicker.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor,
                                                   constant: 10),
            minutesPicker.heightAnchor.constraint(equalTo: popUpView.heightAnchor,
                                                  multiplier: 0.6),
            minutesPicker.widthAnchor.constraint(equalTo: popUpView.widthAnchor,
                                                 multiplier: 0.25),
            
            secondsPicker.leadingAnchor.constraint(equalTo: minutesPicker.trailingAnchor,
                                                   constant: 10),
            secondsPicker.centerYAnchor.constraint(equalTo: popUpView.centerYAnchor,
                                                   constant: -10),
            secondsPicker.heightAnchor.constraint(equalTo: popUpView.heightAnchor,
                                                  multiplier: 0.6),
            secondsPicker.widthAnchor.constraint(equalTo: popUpView.widthAnchor,
                                                 multiplier: 0.25),
            
            cyclesPicker.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor,
                                                   constant: -30),
            cyclesPicker.centerYAnchor.constraint(equalTo: popUpView.centerYAnchor,
                                                  constant: -10),
            cyclesPicker.heightAnchor.constraint(equalTo: popUpView.heightAnchor,
                                                 multiplier: 0.6),
            cyclesPicker.widthAnchor.constraint(equalTo: popUpView.widthAnchor,
                                                multiplier: 0.25),
            
            backButton.bottomAnchor.constraint(equalTo: popUpView.bottomAnchor,
                                               constant: -20),
            backButton.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor,
                                                constant: 13),
            backButton.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor,
                                                 constant: -13),
            backButton.heightAnchor.constraint(equalTo: popUpView.widthAnchor,
                                               multiplier: 0.15)
        ])
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIView.animate(withDuration: 0.15) {
            self.centerConstraint!.constant = 0
            self.popUpView.layer.shadowColor = UIColor.black.cgColor
            self.popUpView.layer.shadowRadius = 80
            self.popUpView.layer.shadowOpacity = 0.3
            self.popUpView.layer.shadowOffset = CGSize(width: 0,
                                                       height: 0)
            self.view.layoutIfNeeded()
        }
    }
    // just dismissing
    @objc func dismis2() {
        downView.backgroundColor = .clear
        UIView.animate(withDuration: 0.15) {
            self.centerConstraint!.constant = UIScreen.main.bounds.width / 1
            self.view.layoutIfNeeded()
        }
        Timer.scheduledTimer(withTimeInterval: 0.15,
                             repeats: false) { _ in
            self.dismiss(animated: false)
        }
    }
    
    private func zeroTimeAttention() {
        let alert = UIAlertController(title: "Внимание!",
                                      message: "Установите длительность таймера!",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок",
                                   style: .default)
        alert.addAction(action)
        self.present(alert,
                     animated: true)
    }
    // dismissing + timer activation
    @objc func dismis() {
        let time = self.minutesPicker.selectedRow(inComponent: 0) % 30 * 1000 * 60 + self.secondsPicker.selectedRow(inComponent: 0) % 60 * 1000
        if time == 0 {
            self.zeroTimeAttention()
        }
        else {
            downView.backgroundColor = .clear
            UIView.animate(withDuration: 0.15) {
                self.centerConstraint!.constant = UIScreen.main.bounds.width / 1
                self.view.layoutIfNeeded()
            }
            Timer.scheduledTimer(withTimeInterval: 0.15,
                                 repeats: false) { _ in
                
                BLE.sharedInstance.startLamp(peripheral: self.device!,
                                             time: time,
                                             cycles: self.cyclesPicker.selectedRow(inComponent: 0) % 10 + 1) { _ in
                }
                self.dismiss(animated: false)
            }
        }
    }
}

extension TimerPopUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        10000
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case cyclesPicker:
            return "\(row % 10 + 1)"
        case minutesPicker:
            return "\(row % 30)"
        default:
            return "\(row % 60)"
        }
    }
}
