//
//  MenuViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/30.
//

import UIKit

class MenuViewController: UIViewController {
    let rowDataList = ["紅燒獅子頭", "清炒高麗菜", "洋蔥爆豬肉"]
    
    let rowDataImage = ["cabbage", "avocado", "boiled"]
    
    let rowDataIngredient = ["3項食材不足", "2項食材不足", "食材已備足"]
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationTitleSetup()
        

        
    
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destVC = segue.destination as? MenuDetailViewController
//    }
    
    func navigationTitleSetup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.view.backgroundColor = .chloeYellow

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as? MenuTableViewCell else { return UITableViewCell() }
        
        cell.menuImageView.image = UIImage(named: self.rowDataImage[indexPath.row])
        cell.menuTitle.text = self.rowDataList[indexPath.row]
        cell.ingredientLabel.text = self.rowDataIngredient[indexPath.row]
        
        return cell
    }
    
    
}
