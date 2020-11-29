//
//  PurchaseListViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/26.
//

import UIKit

class PurchaseListViewController: UIViewController {
    let searchButton = UIButton()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectioView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        tabBarSetup()
        configTableView()
        configColletionView()
        //        navigationbarButtonSetup()
    }
    
    func navigationTitleSetup() {
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.view.backgroundColor = .chloeYellow
    }
    
    func tabBarSetup() {
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
    
    func configColletionView() {
        collectioView.dataSource = self
        collectioView.delegate = self
    }
    
    func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}
extension PurchaseListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 31
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
}
extension PurchaseListViewController: UICollectionViewDelegate {
    
}
extension PurchaseListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PurchaseTableViewCell
        else { return UITableViewCell() }
        
        return cell
    }
    
}
extension PurchaseListViewController: UITableViewDelegate {
    
}
