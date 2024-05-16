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
        switch tableView {
        case infoTableView:
            return 3
        default:
            if connectedDevicesArray.count == 0 {
                noDevices.layer.opacity = 1
            }
            else {
                noDevices.layer.opacity = 0
            }
            return connectedDevicesArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case infoTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell",
                                                           for: indexPath) as? InfoTableViewCell else {
                return InfoTableViewCell()
            }
            cell.setUp(top: infoDataKeys[indexPath.row], bottom: infoData[indexPath.row])
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManagingTableViewCell",
                                                           for: indexPath) as? ManagingTableViewCell else {
                return ManagingTableViewCell()
            }
            let itemsAliasDict = UserDefaultsManager().fetchObject(type: [String : String].self,
                                                                   for: .names) ?? [:]
            
            if let a = itemsAliasDict[connectedDevicesArray[indexPath.row].identifier.uuidString] {
                cell.deviceName.text = a
            }
            else {
                cell.deviceName.text = connectedDevicesArray[indexPath.row].name
            }
            cell.item = connectedDevicesArray[indexPath.row]
            cell.delegateForRename = self
            cell.delegateForInfo = self
            return cell
        }
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
