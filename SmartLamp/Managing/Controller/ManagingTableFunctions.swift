//
//  ManagingTableFunctions.swift
//  SmartLamp
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import Foundation
import UIKit

extension ManagingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if connectedDevicesArray.count == 0 {
            noDevices.layer.opacity = 1
        }
        else {
            noDevices.layer.opacity = 0
        }
        return connectedDevicesArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManagingTableViewCell",
                                                       for: indexPath) as? ManagingTableViewCell else {
            return ManagingTableViewCell()
        }
        cell.deviceName.text = connectedDevicesArray[indexPath.row].name
        cell.item = connectedDevicesArray[indexPath.row]
        return cell
    }
}


extension ManagingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainScreen = MainViewController()
        let device = connectedDevicesArray[indexPath.row]
        mainScreen.device = device
        mainScreen.modalPresentationStyle = .pageSheet
        DispatchQueue.main.async {
            self.present(mainScreen,
                         animated: true)
        }
    }
}
