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
    
    var dataList: [String] = ["Apple", "Lichee", "Orange"] // 預設呈現在畫面上的資料集合
    var filterDataList: [String] = [String]() // 搜尋結果集合
    var searchedDataSource: [String] = ["Avocado", "Banana", "Cherry", "Coconut", "Durian", "Grape", "Grapefruit", "Guava", "Lemon"] // 被搜尋的資料集合
    var isShowSearchResult: Bool = false // 是否顯示搜尋的結果
    
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
        
        self.searchController.searchResultsUpdater = self // 設定代理UISearchResultsUpdating的協議
                self.searchController.searchBar.delegate = self // 設定代理UISearchBarDelegate的協議
                self.searchController.dimsBackgroundDuringPresentation = false // 預設為true，若是沒改為false，則在搜尋時整個TableView的背景顏色會變成灰底的
                
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
extension RecipeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    // MARK: - Search Controller Delegate
        // ---------------------------------------------------------------------
        // 當在searchBar上開始輸入文字時
        // 當「準備要在searchBar輸入文字時」、「輸入文字時」、「取消時」三個事件都會觸發該delegate
//        func updateSearchResults(for searchController: UISearchController) {
//            // 若是沒有輸入任何文字或輸入空白則直接返回不做搜尋的動作
//            if self.searchController.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0 {
//                return
//            }
//
//            self.filterDataSource()
//        }
        
        // 過濾被搜陣列裡的資料
        func filterDataSource() {
            // 使用高階函數來過濾掉陣列裡的資料
            self.filterDataList = searchedDataSource.filter({ (fruit) -> Bool in
                return fruit.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil
            })
            
            if self.filterDataList.count > 0 {
                self.isShowSearchResult = true
                self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.init(rawValue: 1)! // 顯示TableView的格線
            } else {
                self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none // 移除TableView的格線
                // 可加入一個查找不到的資料的label來告知使用者查不到資料...
                // ...
            }
            
            self.tableView.reloadData()
        }
    
    // MARK: - Search Bar Delegate
        // ---------------------------------------------------------------------
        // 當在searchBar上開始輸入文字時
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            // 法蘭克選擇不需實作，因有遵守UISearchResultsUpdating協議的話，則輸入文字的當下即會觸發updateSearchResults，所以等同於同一件事做了兩次(可依個人需求決定，也不一定要跟法蘭克一樣選擇不實作)
        }
        
        // 點擊searchBar上的取消按鈕
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            // 依個人需求決定如何實作
            // ...
        }
        
        // 點擊searchBar的搜尋按鈕時
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            // 法蘭克選擇不需要執行查詢的動作，因在「輸入文字時」即會觸發updateSearchResults的delegate做查詢的動作(可依個人需求決定如何實作)
            // 關閉瑩幕小鍵盤
            self.searchController.searchBar.resignFirstResponder()
        }
    
}
