//
//  FoodListViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/25.
//

import UIKit
import Firebase
import FirebaseFirestore

class FoodListViewController: UIViewController {
    
    let sectionDataList: [String] = ["甲類", "乙類", "丙類"]
        let cellDataList: [[String]] = [["甲-A", "甲-B", "甲-C"],
                                        ["乙-A", "乙-B", "乙-C", "乙-D", "乙-E"],
                                        ["丙-A", "丙-B", "丙-C", "丙-D", "丙-E", "丙-F", "丙-G"]]
    
    var isExpendDataList: [Bool] = [false, false, false]
    
    let searchButton = UIButton()
    var database: Firestore!
    var showCategory: ShowCategory = .all
    
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    @IBOutlet weak var fliterBarButton: UIBarButtonItem!
    
    @IBOutlet weak var allButton: UIButton!{
        didSet {
            allButton.setTitleColor(.chloeYellow, for: .normal)
            allButton.tintColor = UIColor.chloeYellow
        }
    }
    
    @IBOutlet weak var soonExpiredButton: UIButton!
    @IBOutlet weak var expiredButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        tabBarSetup()
        configTableView()
        
        let sectionViewNib: UINib = UINib(nibName: "SectionView", bundle: nil)
        self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "SectionView")
               
        let cellViewNib: UINib = UINib(nibName: "CellView", bundle: nil)
        self.tableView.register(cellViewNib, forCellReuseIdentifier: "CellView")
    }
    
    func navigationTitleSetup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func tabBarSetup() {
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
    
    func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func allPressed(_ sender: UIButton) {
        showCategory = .all
        btnPressedAnimation(type: .all)
        btnPressedColor(type: .all)
        
    }
    
    @IBAction func soonExpiredPressed(_ sender: UIButton) {
        showCategory = .soonExpired
        btnPressedAnimation(type: .soonExpired)
        btnPressedColor(type: .soonExpired)
        
    }
    
    @IBAction func expiredPressed(_ sender: UIButton) {
        showCategory = .expired
        btnPressedAnimation(type: .expired)
        btnPressedColor(type: .expired)
        
    }
    
    func btnPressedColor(type: ShowCategory) {
        switch showCategory {
        case .all:
            allButton.setTitleColor(.chloeYellow, for: .normal)
            soonExpiredButton.setTitleColor(.chloeBlue, for: .normal)
            expiredButton.setTitleColor(.chloeBlue, for: .normal)
            allButton.tintColor = UIColor.chloeYellow
            soonExpiredButton.tintColor = UIColor.chloeBlue
            expiredButton.tintColor = UIColor.chloeBlue
        case .soonExpired:
            soonExpiredButton.setTitleColor(.chloeYellow, for: .normal)
            allButton.setTitleColor(.chloeBlue, for: .normal)
            expiredButton.setTitleColor(.chloeBlue, for: .normal)
            soonExpiredButton.tintColor = UIColor.chloeYellow
            allButton.tintColor = UIColor.chloeBlue
            expiredButton.tintColor = UIColor.chloeBlue
        case .expired:
            expiredButton.setTitleColor(.chloeYellow, for: .normal)
            allButton.setTitleColor(.chloeBlue, for: .normal)
            soonExpiredButton.setTitleColor(.chloeBlue, for: .normal)
            expiredButton.tintColor = UIColor.chloeYellow
            allButton.tintColor = UIColor.chloeBlue
            soonExpiredButton.tintColor = UIColor.chloeBlue
        }
        
    }
    
    func btnPressedAnimation(type: ShowCategory) {
        
        switch showCategory {
        case .all:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = 0
            }
    
        case .soonExpired:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = (self.view.frame.width)/3
            }
        case .expired:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = (self.view.frame.width)/3*2
            }
        }
    }
    
}

extension FoodListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.isExpendDataList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isExpendDataList[section] {
            return self.cellDataList[section].count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellView = tableView.dequeueReusableCell(withIdentifier: "CellView", for: indexPath) as? CellView
        else { return UITableViewCell() }
        
        cell.titleLabel.text = self.cellDataList[indexPath.section][indexPath.row]
        
        return cell
    }
    
}

extension FoodListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let sectionView: SectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionView") as? SectionView
        else { return UIView() }

        sectionView.isExpand = self.isExpendDataList[section]
        sectionView.buttonTag = section
        sectionView.delegate = self

        sectionView.moreData.setTitle(self.isExpendDataList[section] == true ? "↓" : "↑", for: .normal)

        // 名字
        sectionView.foodTitleLabel.text = self.sectionDataList[section]

        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 100
       }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

extension FoodListViewController: SectionViewDelegate {
    
    func sectionView(_ sectionView: SectionView, _ didPressTag: Int, _ isExpand: Bool) {
        self.isExpendDataList[didPressTag] = !isExpand
        self.tableView.reloadSections(IndexSet(integer: didPressTag), with: .automatic)
    }
    
}
