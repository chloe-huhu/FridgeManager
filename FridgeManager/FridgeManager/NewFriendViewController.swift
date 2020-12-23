//
//  NewFriendViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


class NewFriendViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func joinFridge(_ sender: FancyButton) {
        let alterController = UIAlertController(title: "請輸入代碼", message: nil, preferredStyle: .alert)
        
        alterController.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        let okAction = UIAlertAction(title: "加入冰箱", style: .default) { (_) in
            
            guard  let fridgeName = alterController.textFields?[0].text else { return }
            
            let userDoc = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
            
            userDoc.updateData(["myFridges": Firebase.FieldValue.arrayUnion([fridgeName])])
            
            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
            
            viewController.modalPresentationStyle = .fullScreen
            
            self.present(viewController, animated: true, completion: nil)
            
        }
        alterController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alterController.addAction(cancelAction)
        
        self.present(alterController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addNewFridge(_ sender: FancyButton) {
        
        let alterController = UIAlertController(title: "輸入冰箱名稱", message: nil, preferredStyle: .alert)
        
        alterController.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        let okAction = UIAlertAction(title: "新增", style: .default) { (_) in
            
            guard  let fridgeName = alterController.textFields?[0].text else { return }
            
            self.addNewFridgeSetup(name: fridgeName)
            
            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
            
            viewController.modalPresentationStyle = .fullScreen
            
            self.present(viewController, animated: true, completion: nil)
            
        }
        alterController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alterController.addAction(cancelAction)
        
        self.present(alterController, animated: true, completion: nil)
        
    }
    
    
    func addNewFridgeSetup (name: String) {
        
        let doc = Firestore.firestore().collection("fridges").document()
        
        doc.setData([
            "category": ["肉類", "豆類", "雞蛋類", "青菜類", "醃製類", "水果類", "魚類", "海鮮類", "五穀根筋類", "飲料類", "調味料類", "其他"],
            "fridgeID": doc.documentID,
            "fridgeName": name,
            "users": [Auth.auth().currentUser?.email]
        ])
        
        // 將新增的冰箱ID存起來
        UserDefaults.standard.setValue(doc.documentID, forKey: "FridgeID")
        
        // 將新建的冰箱ID加到myFridges
        let userDoc = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        userDoc.updateData(["myFridges": Firebase.FieldValue.arrayUnion([doc.documentID])])
        
    }
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
