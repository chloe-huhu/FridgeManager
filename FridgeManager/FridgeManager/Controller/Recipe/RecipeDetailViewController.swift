//
//  RecipeDetailViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/22.
//

import UIKit

class RecipeDetailViewController: UIViewController {
    
    var showRecipe: [ShowRecipe] = [.image, .indregient, .content]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
}

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch showRecipe[section] {
        
        case .image:
            return 0
        
        case.indregient:
            return 50
        
        case.content:
            return 50
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // header 位置、文字、背景顏色、文字顏色、字型修改
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        headerView.backgroundColor = UIColor.white
        
        let headerLabel = UILabel()
        
        headerLabel.frame = CGRect.init(x: 8, y: 0, width: tableView.frame.width, height: 50)

        switch showRecipe[section] {
        
        case .image:
            headerLabel.text = nil
        
        case.indregient:
            headerLabel.text =  "食材"
        
        case.content:
            headerLabel.text = "步驟"
            
        }
        
        headerLabel.backgroundColor = UIColor.white
        
        headerLabel.textColor = UIColor { _ in return UIColor(red: 63.0 / 255.0, green: 58.0 / 255.0, blue: 58.0 / 255.0, alpha: 1.0)
        }
        
        headerLabel.font = UIFont(name: "PingFangTC-Semibold", size: 18)
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 500
        }else{
            return UITableView.automaticDimension
        }
        
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch showRecipe[section] {
        
        case .image:
            return 1
       
        case.indregient:
            return 5
        
        case.content:
            return 1
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch showRecipe[indexPath.section] {
        
        case .image:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageData", for: indexPath) as? ImageTableViewCell else { return UITableViewCell() }
            
            return cell
      
        case.indregient:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientData", for: indexPath) as? IngredientsTableViewCell else { return UITableViewCell() }
            
            return cell
      
        
        case.content:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentData", for: indexPath) as? ContentTableViewCell else { return UITableViewCell() }
            
            return cell
      
        }
        
    }
}
