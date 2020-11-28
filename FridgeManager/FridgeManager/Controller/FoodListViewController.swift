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
    
    
    let searchButton = UIButton()
    var database: Firestore!
    var showCategory: ShowCategoryCategory = .all
    
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    @IBOutlet weak var fliterBarButton: UIBarButtonItem!
    
    @IBOutlet weak var allButton: UIButton!{
        didSet {
            allButton.setTitleColor(.chloeYellow, for: .normal)
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
        allButton.setTitleColor(.chloeYellow, for: .normal)
        soonExpiredButton.setTitleColor(.chloeBlue, for: .normal)
        expiredButton.setTitleColor(.chloeBlue, for: .normal)
        categoryButtonPressed(type: .all)
    }
    
    @IBAction func soonExpiredPressed(_ sender: UIButton) {
        showCategory = .soonExpired
        soonExpiredButton.setTitleColor(.chloeYellow, for: .normal)
        allButton.setTitleColor(.chloeBlue, for: .normal)
        soonExpiredButton.setTitleColor(.chloeYellow, for: .normal)
        categoryButtonPressed(type: .soonExpired)
    }
    
    @IBAction func expiredPressed(_ sender: UIButton) {
        showCategory = .expired
        allButton.setTitleColor(.chloeBlue, for: .normal)
        soonExpiredButton.setTitleColor(.chloeBlue, for: .normal)
        expiredButton.setTitleColor(.chloeYellow, for: .normal)
        categoryButtonPressed(type: .expired)
    }
    
    func categoryButtonPressed(type: ShowCategoryCategory) {
        
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
extension FoodListViewController: UITableViewDelegate {
    
}
extension FoodListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as? FoodListTableViewCell
        else { return UITableViewCell()v}
        
        return cell
    }
    
    
}
