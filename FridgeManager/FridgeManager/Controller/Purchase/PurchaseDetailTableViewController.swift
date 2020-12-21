//
//  PurchaseDetailTableViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/7.
//

import UIKit
import Firebase
import FirebaseFirestore
import Kingfisher

class PurchaseDetailTableViewController: UITableViewController {
    
    var fridgeID: String {
        guard let fridgeID = UserDefaults.standard.string(forKey: .fridgeID) else  {
            return ""
        }
        
        return fridgeID
    }
    
    
    var userDisplayName = String()
    
    func getUserDisplayName(handler: @escaping () -> Void) {
        
        guard let userUid = UserDefaults.standard.value(forKey: "userUid") as? String else { return }
        
        
        
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: userUid).getDocuments { (querySnapshot, _ ) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                print("\(document.documentID) => \(document.data())")
                    do {
                        let data = try document.data(as: User.self)
                        self.userDisplayName = data!.displayName
                        handler()
                    } catch {
                        print("error to decode", error)
                    }
                }
            }
        }
        
    }
    
    var acceptRef: CollectionReference {
       return
        Firestore.firestore().collection("fridges").document(fridgeID).collection("accept")
    }
    
    var isAwaiting = Bool()
    
    var selectedList: List?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        if isAwaiting == true {
            setupAwaitingBarBtnItem()
            finishedPurchaseButton.isHidden = true
        } else {
            setupAcceptBarBtnItem()
            finishedPurchaseButton.isHidden = false
        }
       
    }
    
    @IBOutlet weak var whoBuyLabel: UILabel! {
        didSet {
            whoBuyLabel.layer.cornerRadius = 8
            whoBuyLabel.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            
            if let photo = selectedList?.photo {
            
                let purchasePhoto = URL(string: photo)
                
                imageView.kf.setImage(with: purchasePhoto, options: [.transition(.fade(0.5))])
                
            } else {
                imageView.image = UIImage(systemName: "photo")
            }
        }
    }
    
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

            noteLabel.text = selectedList?.note
        }
    }
    
    @IBOutlet weak var finishedPurchaseButton: UIButton! {
        didSet {
            finishedPurchaseButton.layer.cornerRadius = 8
            finishedPurchaseButton.clipsToBounds = true
        }
    }
    
    @IBAction func finishedPurchaseBtnTapped(_ sender: UIButton) {
        // accept firebase 刪掉
        deleteAccept()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "SegueAddFood" {
            
            let destVC = segue.destination as? AddFoodTableViewController
            
            destVC?.segueText = selectedList
        }
    }
    
    func setupAwaitingBarBtnItem () {
        let img = UIImage(named: "check-mark")
        let rightBtn = UIBarButtonItem(image: img, style: UIBarButtonItem.Style.plain, target: self, action: #selector(iWillBuyBtnTapped))
        navigationItem.rightBarButtonItem = rightBtn
    }
    
    @objc func iWillBuyBtnTapped() {
        addAccept()
        deleteAwaiting()
        navigationController?.popViewController(animated: true)
    }
    
    func addAccept() {
        
        guard let name = selectedList?.name,
              let amount = selectedList?.amount,
              let unit = selectedList?.unit,
              let brand = selectedList?.brand,
              let place = selectedList?.place,
              let note = selectedList?.note
        
        else { return }
        
        let ref = Firestore.firestore().collection("fridges").document(fridgeID).collection("accept")
        
        let document = ref.document()
        
        getUserDisplayName {
            
            let data: [String: Any] = [
                "id": document.documentID,
                "photo": self.selectedList?.photo as Any,
                "name": name,
                "amount": Int(amount) ,
                "unit": unit,
                "brand": brand,
                "place": place,
                "whoBuy": self.userDisplayName,
                "note": note
            ]
            
            document.setData(data)
        }
    }
    
    func deleteAwaiting() {
        guard let id = selectedList? .id else { return }
        let ref = Firestore.firestore().collection("fridges").document(fridgeID).collection("awaiting")
        ref.document(id).delete() { err in
            if let err = err {
                print("Error removing document :\(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        
    }
    
    func setupAcceptBarBtnItem() {
        let img = UIImage(named: "close")
        let rightBtn = UIBarButtonItem(image: img, style: UIBarButtonItem.Style.plain, target: self, action: #selector(cantBuyBtnTapped))
        navigationItem.rightBarButtonItem = rightBtn
    }
    
    @objc func cantBuyBtnTapped() {
        deleteAccept()
        addAwaiting()
        navigationController?.popViewController(animated: true)
    }
    
    func deleteAccept() {
        guard let id = selectedList? .id else { return }
       
        let ref = Firestore.firestore().collection("fridges").document(fridgeID).collection("accept")
        ref.document(id).delete() { err in
            if let err = err {
                print("Error removing document :\(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func addAwaiting() {
       
        guard let name = selectedList?.name,
              let amount = selectedList?.amount,
              let unit = selectedList?.unit,
              let brand = selectedList?.brand,
              let place = selectedList?.place,
              let note = selectedList?.note
        
        else { return }
        
        let ref = Firestore.firestore().collection("fridges").document(fridgeID).collection("awaiting")
        
        let document = ref.document()
        
        let data: [String: Any] = [
            "id": document.documentID,
            "photo": "test",
            "name": name,
            "amount": Int(amount) ,
            "unit": unit,
            "brand": brand,
            "place": place,
            "whoBuy": "",
            "note": note
        ]
        
        document.setData(data)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    
}
