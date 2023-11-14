//
//  ViewController.swift
//  navigationTraining
//
//  Created by Nikita Stepanov on 26.09.2023.
//

import UIKit

final class CustomTabBarController: UITabBarController {
    
    private enum Images {
        static let home = UIImage(systemName: "name")
        static let profile = UIImage(systemName: "name")
    }
    private enum TabBarItem: Int {
        case manager
        case connector
        var title: String {
            switch self {
            case .manager:
                return "Управление"
            case .connector:
                return "Подключить"
            }
        }
        var iconName: String {
            switch self {
            case .manager:
                return "house"
            case .connector:
                return "point.3.connected.trianglepath.dotted"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
        view.backgroundColor = .systemBackground
    }
    
    private func setupTabBar() {
        let dataSource: [TabBarItem] = [.manager, .connector]
        self.viewControllers = dataSource.map {
            switch $0 {
            case .manager:
                let managingViewController = ManagingViewController()
                return self.wrappedInNavigationController(with: managingViewController,
                                                          title: $0.title)
            case .connector:
                let connectionViewController = ConnectionViewController()
                return self.wrappedInNavigationController(with: connectionViewController,
                                                          title: $0.title)
            }
        }
        self.viewControllers?.enumerated().forEach {
            $1.tabBarItem.title = dataSource[$0].title
            $1.tabBarItem.image = UIImage(systemName: dataSource[$0].iconName)
            $1.tabBarItem.imageInsets = UIEdgeInsets(top: 35,
                                                     left: .zero,
                                                     bottom: -35,
                                                     right: .zero)
        }
    }
    private func wrappedInNavigationController(with: UIViewController,
                                               title: Any?) -> UINavigationController {
        let controller = UINavigationController(rootViewController: with)
        return controller
    }
}
