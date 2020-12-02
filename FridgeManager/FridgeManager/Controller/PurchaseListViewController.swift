//
//  PurchaseListViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/26.
//

import UIKit

class PurchaseListViewController: UIViewController {
   
    let sectionImage: [String] = ["pencil.circle.fill", "pencil.circle.fill"]
    
    let sectionDataList: [String] = ["未採購", "採購中"]
    
    let cellDataTitle: [[String]] = [["香蕉", "Costco 牛排", "雞蛋"],
                                    ["海底撈火鍋料", "高麗菜", "洋蔥圈", "厚片吐司"]]
    
    let cellDataAmount: [[String]] = [["6 根", "1 盒", "1 盒"],
                                    ["2 包", "半 顆", "1 包", "6 片"]]
    
    let cellDataWho: [[String]] = [["?", "?", "?"],
                                    ["Chloe", "Jeff", "Soda", "Chloe"]]
    
    var isExpendDataList: [Bool] = [true, true]
    
    let searchButton = UIButton()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var taskDateTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        tabBarSetup()
        configTableView()
        configNib()
        
    }
    
    func navigationTitleSetup() {
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.view.backgroundColor = .chloeYellow
    }
    
    func tabBarSetup() {
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
    
    func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func configNib() {
        let sectionViewNib: UINib = UINib(nibName: "PurchaseSectionView", bundle: nil)
        self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "PurchaseSectionView")
        
        let cellNib: UINib = UINib(nibName: "PurchaseTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "CellView")
    }
}
extension PurchaseListViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionView: PurchaseSectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PurchaseSectionView") as? PurchaseSectionView else { return UIView() }
        
        sectionView.isExpand = self.isExpendDataList[section]
        sectionView.buttonTag = section
        sectionView.delegate = self
        
        sectionView.imageView.image = UIImage(systemName: self.sectionImage[section])
        
        sectionView.pendingLabel.text = self.sectionDataList[section]
        
        return sectionView
    }
}

extension PurchaseListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.isExpendDataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if self.isExpendDataList[section] {
            return self.cellDataTitle[section].count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellView", for: indexPath) as? PurchaseTableViewCell
        else { return UITableViewCell() }
        
        cell.titleLabel.text = self.cellDataTitle[indexPath.section][indexPath.row]
        cell.amountLabel.text = self.cellDataAmount[indexPath.section][indexPath.row]
        cell.whoLabel.text = self.cellDataWho[indexPath.section][indexPath.row]
       
        return cell
    }
    
}

extension PurchaseListViewController: PurchaseSectionViewDelegate {
    func sectionView(_ sectionView: PurchaseSectionView, _ didPressTag: Int, _ isExpand: Bool) {
        self.isExpendDataList[didPressTag] = !isExpand
        self.tableView.reloadSections(IndexSet(integer: didPressTag), with: .automatic)
    }
    
}
