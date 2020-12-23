//
//  RecipeDetailViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/22.
//

import UIKit


class RecipeDetailViewController: UIViewController {
    
    var selectedRecipe: Recipe?
    
    var showRecipe: [ShowRecipe] = [.image, .indregient, .content]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        guard let recipe = selectedRecipe?.id else { return }
        self.navigationItem.title = "\(recipe)"
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
        
        headerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        let headerLabel = UILabel()
        
        headerLabel.frame = CGRect.init(x: 16, y: 0, width: tableView.frame.width, height: 50)

        switch showRecipe[section] {
        
        case .image:
            headerLabel.text = nil
        
        case.indregient:
            headerLabel.text =  "所需食材"
        
        case.content:
            headerLabel.text = "烹飪步驟"
            
        }
        
        headerLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        headerLabel.textColor = #colorLiteral(red: 1, green: 0.6047399044, blue: 0.2367118895, alpha: 1)
        
        headerLabel.font = UIFont(name: "PingFangTC-Semibold", size: 18)
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 350
        } else if indexPath.section == 1 {
            
            return UITableView.automaticDimension
        } else {
            
            return UITableView.automaticDimension
        }
        
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        guard let recipe = selectedRecipe else { return 0 }
        
        switch showRecipe[section] {
        
        case .image:
            return 1
       
        case.indregient:
            return (selectedRecipe?.ingredients.count)!
        
        case.content:
            return (selectedRecipe?.content.count)!
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let recipe = selectedRecipe else {
            return UITableViewCell()
        }
        
        switch showRecipe[indexPath.section] {
        
        case .image:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageData", for: indexPath) as? ImageTableViewCell else { return UITableViewCell() }
            
            cell.setup(data: recipe)
            
            return cell
      
        case.indregient:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientData", for: indexPath) as? IngredientsTableViewCell else { return UITableViewCell() }
            
            cell.setup(data: recipe.ingredients[indexPath.row])
            
            return cell
      
        
        case.content:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentData", for: indexPath) as? ContentTableViewCell else { return UITableViewCell() }
            
            cell.setup(data: recipe.content[indexPath.row])
            
            return cell
      
        }
        
    }
}
