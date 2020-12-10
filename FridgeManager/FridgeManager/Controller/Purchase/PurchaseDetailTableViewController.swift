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
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = selectedList?.name
            
        }
    }
    
    @IBOutlet weak var amountUnitLabel: UILabel! {
        didSet {
            guard let amount = selectedList?.amount else { return }
            guard let unit = selectedList?.unit else { return }
            amountUnitLabel.text = " \(amount) \(unit) "
        }
    }
    @IBOutlet weak var brandLabel: UILabel! {
        didSet {
            brandLabel.text = selectedList?.brand
        }
    }
    @IBOutlet weak var placeLabel: UILabel! {
        didSet {
            placeLabel.text = selectedList?.place
        }
    }
    
    @IBOutlet weak var noteLabel: UILabel! {
        didSet {
//            noteLabel.lineBreakMode = .byWordWrapping
//            noteLabel.numberOfLines = 0
            noteLabel.text = selectedList?.note
        }
    }
    
//    var isAwaiting = Bool()
    
    var selectedList: List?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarBtnItem()

    }

    func setupBarBtnItem () {
        let img = UIImage(systemName: "person.crop.circle.badge.questionmark")
        let rightButton = UIBarButtonItem(image: img, style: UIBarButtonItem.Style.plain, target: self, action: #selector(rightNavBarItemAction))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func rightNavBarItemAction() {
        print("採購")
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

   
}
