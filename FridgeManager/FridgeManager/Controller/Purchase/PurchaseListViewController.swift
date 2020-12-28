//
//  PurchaseListViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/26.
//

import UIKit
import Firebase
import FirebaseFirestore
import Lottie

class PurchaseListViewController: UIViewController {
    
    var fridgeID: String {
       
        guard let fridgeID = UserDefaults.standard.string(forKey: .fridgeID) else  {
           
            return ""
        }
        
        return fridgeID
    }
    
    var awaitingRef: CollectionReference {
        return Firestore.firestore().collection("fridges").document(fridgeID).collection("awaiting")
    }
    
    var acceptRef: CollectionReference {
       return
        Firestore.firestore().collection("fridges").document(fridgeID).collection("accept")
    }
    
    var awaitingList = [List]()
    
    var acceptLists = [List]()
    
    var whoBuyArray = [String]()
    
    let sectionImage: [String] = ["close", "check-mark"]
    
    let sectionDataList: [String] = ["未採購", "採購中"]
    
    let searchButton = UIButton()
    
    var isAwaiting = Bool()
    
    var selectedList: List?
    
    var showType: ShowType = .edit
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        tabBarSetup()
//        dblistenAwating()
//        dblistenAccept()
        emptyLabel.isHidden = true
        animationView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        dblistenAwating()
        dblistenAccept()
        tableView.reloadData()
    }
    
    func setupEmpty() {
        if awaitingList.isEmpty && acceptLists.isEmpty {
            emptyLabel.isHidden = false
            animationView.isHidden = false
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .autoReverse
            animationView.animationSpeed = 0.5
            animationView.play()
        } else {
            emptyLabel.isHidden = true
            animationView.isHidden = true
        }
    }
    
    @IBOutlet weak var animationView: AnimationView!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    // 頁面設定
    func navigationTitleSetup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func tabBarSetup() {
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
        
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            
            tableView.allowsMultipleSelection = true
            tableView.allowsMultipleSelectionDuringEditing = true
            
            let sectionViewNib: UINib = UINib(nibName: "PurchaseSectionView", bundle: nil)
            self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "PurchaseSectionView")
            
            let cellNib: UINib = UINib(nibName: "PurchaseTableViewCell", bundle: nil)
            self.tableView.register(cellNib, forCellReuseIdentifier: "CellView")
        }
    }
    
    // 使用者按下編輯按鈕
    @IBOutlet weak var barBtnItem: UIBarButtonItem!
    
    @IBAction func editBtnTapped(_ sender: UIBarItem) {
        selectedData()
    }
    
    func selectedData() {
        switch showType {
        case .edit:
            barBtnItem.image = #imageLiteral(resourceName: "trash")
            tableView.isEditing = !tableView.isEditing
            tableView.reloadData()
            showType = .delete
        case .delete:
            barBtnItem.image = #imageLiteral(resourceName: "folder.png")
            showType = .edit
            deleteRows()
            tableView.isEditing = !tableView.isEditing
            tableView.reloadData()
        }
    }
    
    func deleteRows() {
      
        if let seletedRows = tableView.indexPathsForSelectedRows {
            
            var selectedItems: [List] = []
            
            for indexPath in seletedRows {
               
                if indexPath.section == 0 {
                    selectedItems.append(awaitingList[indexPath.row])
                } else {
                    selectedItems.append(acceptLists[indexPath.row])
                }
                print(selectedItems)
            }
            
            for selecteditem in selectedItems {
                
                if selecteditem.whoBuy == "" {

                    awaitingRef.document(selecteditem.id).delete()
                } else {
                    
                    acceptRef.document(selecteditem.id).delete()
                }

            }
        }
    }
   
  // firebase 監聽
    func dblistenAwating() {
        
        FirebaseManager.shared.listen(ref: awaitingRef) {
            
            self.dbGetAwaiting()
        }
    }
    
    func dblistenAccept() {
        
        FirebaseManager.shared.listen(ref: acceptRef) {
            
            self.dbGetAccept()
        }
    }
    
    // firebase 取得資料awaitingList＆acceptLists
    func dbGetAwaiting() {

        awaitingRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                self.awaitingList.removeAll()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        
                        let data = try document.data(as: List.self)
                        
                        self.awaitingList.append(data!)
                        
                    } catch {
                        print("error to decode", error)
                    }
                    
                }
                
                self.tableView.reloadData()
            }
            
            
        }
        
    }
    
    var isLoading = false
    
    func dbGetAccept() {

        if !isLoading {

            isLoading = true
            acceptRef.getDocuments { (querySnapshot, err) in
                self.isLoading = false
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    self.acceptLists.removeAll()
                    self.whoBuyArray.removeAll()
                    
                    for document in querySnapshot!.documents {

                        do {
                            
                            let data = try document.data(as: List.self)
                            
                            self.acceptLists.append(data!)
                            
//                            self.tableView.reloadData()
                            
                        } catch {
                            
                            print("error to decode", error)
                        }
                        
                    }
                    
                    for acceptList in self.acceptLists {
                        
                        self.getUserDisplayName(who: acceptList.whoBuy) { whoBuy in

                            self.whoBuyArray.append(whoBuy)

                            self.tableView.reloadData()
                        }
                    }
                    
                    self.tableView.reloadData()
                }
                
            }
        }
        
        
    }
    
    // uid -> displayName
    func getUserDisplayName(who: String, handler: @escaping (String) -> Void) {
       
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: who).getDocuments { (querySnapshot, _ ) in
            if let querySnapshot = querySnapshot {
                
                for document in querySnapshot.documents {
                print("\(document.documentID) => \(document.data())")
                    do {
                        let data = try document.data(as: User.self)
                        
                        guard let whoBuy = data?.displayName else { return }
                        
                        handler(whoBuy)

                    } catch {
                        print("error to decode", error)
                    }
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destVC = segue.destination as? PurchaseDetailTableViewController
        
        destVC?.selectedList = selectedList
        
        destVC?.isAwaiting = isAwaiting
        
    }
    
}
extension PurchaseListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionView: PurchaseSectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PurchaseSectionView") as? PurchaseSectionView else { return UIView() }
        
        sectionView.imageView.image = UIImage(named: sectionImage[section])
        
        sectionView.pendingLabel.text = self.sectionDataList[section]
        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        isAwaiting = indexPath.section == 0 ? true : false
            
        selectedList = isAwaiting ? awaitingList[indexPath.row] : acceptLists[indexPath.row]
        
        if !tableView.isEditing {
            self.performSegue(withIdentifier: "SeguePurchaseDetail", sender: nil)
        }
       
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
//            return acceptLists.count
            return whoBuyArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellView", for: indexPath) as? PurchaseTableViewCell
        else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            
            cell.setup(data: awaitingList[indexPath.row], whoBuy: "")

            return cell
            
        } else {
            
            cell.setup(data: acceptLists[indexPath.row], whoBuy: whoBuyArray[indexPath.row])
            
            return cell
        }
    }
}
