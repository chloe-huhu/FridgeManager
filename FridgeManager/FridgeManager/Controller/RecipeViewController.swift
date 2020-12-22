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
    
    var searchController: UISearchController!
    
    
    let rowDataImage = ["cabbage", "avocado", "boiled"]
    
    let rowDataIngredient = ["3項食材不足", "2項食材不足", "食材已備足"]
    
    let ref = Firestore.firestore().collection("recipe")
    
    var recipeList: [Recipe] = []
    
     @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        listenRecipe()
        setupSearch()
    }
    
    
    func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.placeholder = "請輸入食材名稱"
                
                // 將searchBar掛載到tableView上
        self.tableView.tableHeaderView = self.searchController.searchBar

    
    }
    func listenRecipe() {
        FirebaseManager.shared.listen(ref: ref) {
            self.getRecipe()
        }
    }
    
    
    func getRecipe() {
        ref.getDocuments { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.recipeList = []

                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    do {
                        let data = try document.data(as: Recipe.self)
                        self.recipeList.append(data!)
                    } catch {
                        print("error to decode", error)
                    }
                    
                }
                self.tableView.reloadData()
            }
            
        }
    }
    
    func navigationTitleSetup() {
        navigationController?.navigationBar.backgroundColor = .chloeYellow
        navigationController?.view.backgroundColor = .chloeYellow
        navigationController?.navigationBar.barTintColor = .chloeYellow
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

}


extension RecipeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "SegueRecipeDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as? RecipeTableViewCell else { return UITableViewCell() }
        
    
       
//        cell.menuTitle.text = [indexPath.row]
        cell.ingredientLabel.text = self.rowDataIngredient[indexPath.row]
       
        cell.menuImageView.image = UIImage(named: self.rowDataImage[indexPath.row])
       
        cell.setup(data: recipeList[indexPath.row])
        
        return cell
        
    }
    
    
}

