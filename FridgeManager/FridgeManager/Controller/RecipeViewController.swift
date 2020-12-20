//
//  MenuViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/30.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class RecipeViewController: UIViewController {
    
    let rowDataList = ["紅燒獅子頭", "清炒高麗菜", "洋蔥爆豬肉"]
    
    let rowDataImage = ["cabbage", "avocado", "boiled"]
    
    let rowDataIngredient = ["3項食材不足", "2項食材不足", "食材已備足"]
    
    let ref = Fire
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
    }
    
    
    func navigationTitleSetup() {
        navigationController?.navigationBar.backgroundColor = .chloeYellow
        navigationController?.view.backgroundColor = .chloeYellow
        navigationController?.navigationBar.barTintColor = .chloeYellow
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

}

extension RecipeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as? RecipeTableViewCell else { return UITableViewCell() }
        
        cell.menuImageView.image = UIImage(named: self.rowDataImage[indexPath.row])
        cell.menuTitle.text = self.rowDataList[indexPath.row]
        cell.ingredientLabel.text = self.rowDataIngredient[indexPath.row]
        
        return cell
        
    }
    
    
}
