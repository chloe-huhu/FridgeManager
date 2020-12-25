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
    
    // 重設filteredArray後重整tableview
    var filteredArray: [Recipe] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
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
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = false
    }
    
    func setupSearch() {
        
        // 建立searchController 設置搜索控制器為nil
        searchController = UISearchController(searchResultsController: nil)
                
        self.navigationItem.searchController = searchController
        
        // 將更新搜尋結果的對象設為 self
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.searchBarStyle = .minimal
        
        // 搜尋時是否使用燈箱效果 (會將畫面變暗以集中搜尋焦點)
        searchController.dimsBackgroundDuringPresentation = false
      
        self.searchController.searchBar.placeholder = "請輸入食材名稱"
        
        navigationItem.hidesSearchBarWhenScrolling = false
      
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
//                    print("\(document.documentID) => \(document.data())")
                    
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
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        navigationController?.navigationBar.backgroundColor = .chloeYellow
        navigationController?.navigationBar.barTintColor = .chloeYellow
        
        if #available(iOS 13.0, *) {
                let app = UIApplication.shared
                let statusBarHeight: CGFloat = app.statusBarFrame.size.height
                let statusbarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarHeight))
                statusbarView.backgroundColor = UIColor.chloeYellow
                view.addSubview(statusbarView)
            } else {
                let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
                statusBar?.backgroundColor = UIColor.chloeYellow
            }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as? RecipeDetailViewController
        
        destVC?.selectedRecipe = selectedRecipe
    }

}


extension RecipeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if self.searchController.isActive {
            selectedRecipe = filteredArray[indexPath.row]
        } else {
            selectedRecipe = recipeList[indexPath.row]
        }

        self.performSegue(withIdentifier: "SegueRecipeDetail", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchController.isActive {
                return filteredArray.count
            } else {
                return recipeList.count
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as? RecipeTableViewCell else { return UITableViewCell() }

        
        if self.searchController.isActive {
            cell.setup(data: filteredArray[indexPath.row])
//            cell.menuImageView.image = UIImage(named: self.rowDataImage[indexPath.row])
          } else {
            cell.setup(data: recipeList[indexPath.row])
//            cell.menuImageView.image = UIImage(named: self.rowDataImage[indexPath.row])
          }
       
        return cell
        
    }
}

extension RecipeViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard  let searchText = searchController.searchBar.text else { return }
        
        var array: [Recipe] = []

        for recipe in recipeList {

            for item in recipe.ingredients where item.contains(searchText) {

                print(item, "==", searchText)

                if !array.contains(recipe) {

                    array.append(recipe)
                }
            }
        }
        
        filteredArray = array
    }
    
}
