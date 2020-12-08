//
//  PurchaseListViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/26.
//

import UIKit
import Firebase
import FirebaseFirestore

class PurchaseListViewController: UIViewController {
    
    var awaitingList: [Lists] = []
    
    var acceptLists: [Lists] = []
    
    let sectionImage: [String] = ["person.crop.circle.badge.questionmark", "person.crop.circle.badge.checkmark"]
    
    let sectionDataList: [String] = ["未採購", "採購中"]
    
    
    let cellDataWho: [[String]] = [["等你認領", "等你認領", "等你認領", "等你認領", "等你認領", "等你認領"],
                                   ["Chloe", "Jeff", "Soda", "Chloe", "Chloe", "Jeff", "Soda", "Chloe"]]
    
    let searchButton = UIButton()
    
    var isAwaiting = Bool()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            let sectionViewNib: UINib = UINib(nibName: "PurchaseSectionView", bundle: nil)
            self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "PurchaseSectionView")
            
            let cellNib: UINib = UINib(nibName: "PurchaseTableViewCell", bundle: nil)
            self.tableView.register(cellNib, forCellReuseIdentifier: "CellView")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        tabBarSetup()
        dblistenAwating()
        dblistenAccept()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nextViewController = segue.destination as? PurchaseDetailTableViewController
        
        nextViewController?.isAwaiting = self.isAwaiting
    }
    
    func navigationTitleSetup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)

    }
    
    func tabBarSetup() {
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
    
    func dblistenAwating() {
        let ref = Firestore.firestore().collection("fridges").document("1fK0iw24FWWiGf8f3r0G").collection("awaiting")
        
        FirebaseManager.shared.listen(ref: ref) {
            
            self.dbGetAwaiting()
        }
    }
    
    func dblistenAccept() {
        let ref = Firestore.firestore().collection("fridges").document("1fK0iw24FWWiGf8f3r0G").collection("accept")
        
        FirebaseManager.shared.listen(ref: ref) {
            
            self.dbGetAccept()
        }
    }
    
    func dbGetAwaiting() {
        let ref = Firestore.firestore().collection("fridges").document("1fK0iw24FWWiGf8f3r0G").collection("awaiting")
        
        ref.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                self.awaitingList = []
                
                for document in querySnapshot!.documents {
                    print("待採購：現有的資料 \(document.documentID) => \(document.data())")
                    do {
                        
                        let data = try document.data(as: Lists.self)
                        
                        self.awaitingList.append(data!)
                        
                        self.tableView.reloadData()
                        
                    } catch {
                        print("error to decode", error)
                    }
                    
                }
            }
            
            
        }
        
    }
    
    func dbGetAccept() {
        let ref = Firestore.firestore().collection("fridges").document("1fK0iw24FWWiGf8f3r0G").collection("accept")
        
        ref.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                self.acceptLists = []
                
                for document in querySnapshot!.documents {
                    print("正在採購：現有的資料 \(document.documentID) => \(document.data())")
                    do {
                        
                        let data = try document.data(as: Lists.self)
                        
                        self.acceptLists.append(data!)
                        
                        self.tableView.reloadData()
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                    
                }
            }
            
        }
        
    }
    
    
}
extension PurchaseListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionView: PurchaseSectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PurchaseSectionView") as? PurchaseSectionView else { return UIView() }
        
        sectionView.imageView.image = UIImage(systemName: self.sectionImage[section])
        
        sectionView.pendingLabel.text = self.sectionDataList[section]
        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        isAwaiting = indexPath.section == 0 ? true : false
        
        self.performSegue(withIdentifier: "SeguePurchaseDetail", sender: nil)
    }
}

extension PurchaseListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return awaitingList.count
        } else {
            return acceptLists.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellView", for: indexPath) as? PurchaseTableViewCell
        else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            
            cell.titleLabel.text = awaitingList[indexPath.row].name
            cell.amountLabel.text = "\(awaitingList[indexPath.row].amount)"
            cell.whoLabel.text = self.cellDataWho[indexPath.section][indexPath.row]
            
            return cell
            
        } else {
            
            cell.titleLabel.text = acceptLists[indexPath.row].name
            cell.amountLabel.text = "\(acceptLists[indexPath.row].amount)"
            cell.whoLabel.text = self.cellDataWho[indexPath.section][indexPath.row]
            
            return cell
        }
        
    }
    
    
}
