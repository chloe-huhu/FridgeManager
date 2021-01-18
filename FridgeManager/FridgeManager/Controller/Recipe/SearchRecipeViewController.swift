//
//  SearchRecipeViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/2.
//

import UIKit

class SearchRecipeViewController: UIViewController {
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
    }
    
}
