//
//  PurchaseDetailTableViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/7.
//

import UIKit

class PurchaseDetailTableViewController: UITableViewController {

    @IBOutlet weak var whoBuyLabel: UILabel! {
        didSet {
            whoBuyLabel.layer.cornerRadius = 8
            whoBuyLabel.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    var awaiting = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(awaiting)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

   
}
