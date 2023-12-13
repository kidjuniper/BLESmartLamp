//
//  ConnectionTableFunctions.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import Foundation
import UIKit

extension ConnectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if possibleDevices.count == 0 {
            noDevices.layer.opacity = 1
        }
        else {
            noDevices.layer.opacity = 0
        }
        return possibleDevices.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionTableViewCell",
                                                       for: indexPath) as? ConnectionTableViewCell else {
            return ConnectionTableViewCell()
        }
        if possibleDevices.count > indexPath.row {
            cell.deviceName.text = possibleDevices[indexPath.row].name
            if possibleDevices[indexPath.row].state == .connected {
                cell.changeDeviceNameButton.setImage(UIImage(systemName: "checkmark"),
                                                     for: .normal)
            }
            else {
                cell.changeDeviceNameButton.setImage(UIImage(systemName: "plus"),
                                                     for: .normal)
            }
            cell.item = possibleDevices[indexPath.row]
        }
        return cell
    }
}


extension ConnectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if possibleDevices[indexPath.row].state == .connected {
            let alert = UIAlertController(title: nil,
                                          message: "Перейдите в раздел \"управление\" для работы с устройством",
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
