//
//  PurchaseListViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/26.
//

import UIKit

class PurchaseListViewController: UIViewController {
    let searchButton = UIButton()
  
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationTitleSetup()
        tabBarSetup()
//        navigationbarButtonSetup()
    }
  
    func navigationTitleSetup() {
        navigationItem.title = "採購清單"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.greyishBrown]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
  
    func navigationbarButtonSetup() {
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        let btnImage = UIImage(named: "magnifying-glass")
        searchButton.setImage(btnImage, for: .normal)
//        searchButton.frame = CGRect(x: 340, y: 100, width: 30, height: 30)
        view.addSubview(searchButton)
        guard let titleView = navigationController?.navigationBar.topItem?.titleView else { return }
        NSLayoutConstraint.activate([
            searchButton.widthAnchor.constraint(equalToConstant: 30),
            searchButton.heightAnchor.constraint(equalToConstant: 30),
            searchButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
//            searchButton.topAnchor.constraint(equalTo: navigationController?.centerYAnchor, constant: 200)
        ])
        
    }
    
    func tabBarSetup() {
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
}
