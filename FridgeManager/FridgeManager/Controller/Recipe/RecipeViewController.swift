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
    
    let rowDataImage = ["018-meat-ball", "009-curry-1", "boiled"]

    let ref = Firestore.firestore().collection("recipe")
    
    var recipeList: [Recipe] = []
    
    var selectedRecipe: Recipe?
    
    var searchController: UISearchController!
    
    var shouldShowSearchResults = false
    
    var filteredArray = [Recipe]()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        self.searchController.searchBar.placeholder = "請輸入食材名稱"
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
//        tableView.tableHeaderView = searchController.searchBar
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as? RecipeDetailViewController
        
        destVC?.selectedRecipe = selectedRecipe
    }

}


extension RecipeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        selectedRecipe = recipeList[indexPath.row]
        
        self.performSegue(withIdentifier: "SegueRecipeDetail", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldShowSearchResults {
                return filteredArray.count
            } else {
                return recipeList.count
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as? RecipeTableViewCell else { return UITableViewCell() }

        
        if shouldShowSearchResults {
            cell.setup(data: filteredArray[indexPath.row])
//            cell.menuImageView.image = UIImage(named: self.rowDataImage[indexPath.row])
          } else {
            cell.setup(data: recipeList[indexPath.row])
//            cell.menuImageView.image = UIImage(named: self.rowDataImage[indexPath.row])
          }
       
        return cell
        
    }
}

extension RecipeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
}
 
