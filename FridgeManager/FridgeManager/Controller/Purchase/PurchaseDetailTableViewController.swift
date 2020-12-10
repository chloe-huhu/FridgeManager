//
//  PurchaseDetailTableViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/7.
//

import UIKit
import Firebase
import FirebaseFirestore

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
        addAccept()
        
    }
    
    func addAccept() {
        
        guard let name = selectedList?.name,
              let amount = selectedList?.amount,
              let unit = selectedList?.unit,
              let brand = selectedList?.brand,
              let place = selectedList?.place,
              let note = selectedList?.note
        
        else { return }
        
        let ref = Firestore.firestore().collection("fridges").document("1fK0iw24FWWiGf8f3r0G").collection("accept")
        
        let document = ref.document()
        
        let data: [String: Any] = [
            "id": document.documentID,
            "photo": "test",
            "name": name,
            "amount": Int(amount) ,
            "unit": unit,
            "brand": brand,
            "place": place,
            "whoBuy": "chloe",
            "note": note
        ]
        
        document.setData(data)
    }
    
    func delete() {
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

   
}
