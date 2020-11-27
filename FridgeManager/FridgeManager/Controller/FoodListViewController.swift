//
//  FoodListViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/25.
//

import UIKit
import Firebase
import FirebaseFirestore
import PagingKit

class FoodListViewController: UIViewController {
    
    var database: Firestore!
    let searchButton = UIButton()
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    
    static var viewController: (UIColor) -> UIViewController = { (color) in
        let vc = UIViewController()
        vc.view.backgroundColor = color
        return vc
    }
    
    var dataSource = [
        (menuTitle: "全部食材", vc: viewController(.red)),
        (menuTitle: "準備過期", vc: viewController(.blue)),
        (menuTitle: "已經過期", vc: viewController(.yellow))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        tabBarSetup()
        navigationTitleSetup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuVC = segue.destination as? PagingMenuViewController {
            menuViewController = menuVC
            menuViewController.dataSource = self
            menuViewController.delegate = self
        } else if let contentVC = segue.destination as? PagingContentViewController {
            contentViewController = contentVC
            contentViewController.dataSource = self
            contentViewController.delegate = self
            contentViewController.reloadData()
        }
    }
    
    func navigationTitleSetup() {
        navigationItem.title = "食物列表"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.greyishBrown]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PingFangTC-Semibold", size: 20)!]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func tabBarSetup() {
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
    
    func registerNib() {
        menuViewController.register(nib: UINib(nibName: "MenuCell", bundle: nil), forCellWithReuseIdentifier: "MenuCell")
        menuViewController.registerFocusView(nib: UINib(nibName: "FocusView", bundle: nil))
        menuViewController.reloadData()
    }
}

extension FoodListViewController: PagingMenuViewControllerDataSource {
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        guard let cell = viewController.dequeueReusableCell(
                withReuseIdentifier: "MenuCell",
                for: index) as? MenuCell
        else {
            return PagingMenuViewCell()
        }
        cell.titleLabel.text = dataSource[index].menuTitle
        
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return UIScreen.main.bounds.width / CGFloat(dataSource.count)
    }
}

extension FoodListViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].vc
        
    }
    
}
extension FoodListViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
    
}

extension FoodListViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}
