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
import Lottie


class NewFriendViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWelcome()
        dbListen()
        
    }
    
    @IBOutlet weak var animationView: AnimationView!
    
    // 加入現有冰箱-> 提供QRcode->
    @IBAction func joinFridge(_ sender: FancyButton) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let alterController = UIAlertController(title: "讓冰箱現有成員掃碼\n跳轉後請到「冰箱列表」確認", message: nil, preferredStyle: .alert)
        
        let height = NSLayoutConstraint(item: alterController.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        
        let width = NSLayoutConstraint(item: alterController.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        
        alterController.view.addConstraint(height)
        
        alterController.view.addConstraint(width)
        
        let qrImageView = UIImageView()
        
        qrImageView.image = self.generateQRCode(from: "\(uid)")
        
        alterController.view.addSubview(qrImageView)
        
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            qrImageView.widthAnchor.constraint(equalToConstant: 150),
            qrImageView.heightAnchor.constraint(equalToConstant: 150),
            qrImageView.centerXAnchor.constraint(equalTo: alterController.view.centerXAnchor),
            qrImageView.centerYAnchor.constraint(equalTo: alterController.view.centerYAnchor)
        ])
        
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alterController.addAction(cancelAction)
        
        self.present(alterController, animated: true, completion: nil)
        
    }
    
    func dbListen() {
        
        var ref: ListenerRegistration?
        
        ref = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).addSnapshotListener { (documentSnapshot, _) in
            guard let user = try? documentSnapshot?.data(as: User.self) else { return }
            
            if !user.myInvites.isEmpty {
                
                self.dismiss(animated: true) {
                    
                    self.performSegue(withIdentifier: "SegueHomeVC", sender: nil)
                    
                    ref?.remove()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueHomeVC" {
            
            let tabBarContorller = segue.destination as? UITabBarController
            
            let navigationController = tabBarContorller?.viewControllers?[0] as? UINavigationController
            
            let firstViewController = navigationController?.viewControllers[0] as? FoodListViewController
            
            firstViewController?.modalPresentationStyle = .fullScreen
            
            firstViewController?.goInfo = .newUser
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    @IBAction func addNewFridge(_ sender: FancyButton) {
        
        let alterController = UIAlertController(title: "輸入新冰箱名稱", message: "創建後可以邀請家人一起管理食材", preferredStyle: .alert)
        
        alterController.addTextField { (textField) in
            textField.placeholder = "可愛的家"
        }
        
    
        
        let okAction = UIAlertAction(title: "新增", style: .default) { (_) in
            
            if alterController.textFields?[0].text != "" {
                guard  let fridgeName = alterController.textFields?[0].text  else { return }
                
                self.addNewFridgeSetup(name: fridgeName)
                
                self.performSegue(withIdentifier: "SegueHomeVC", sender: nil)
           
            } else {
               
                let alterController = UIAlertController(title: "Oops!!", message: "你的冰箱名稱是空的！", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
                alterController.addAction(alertAction)
                self.present(alterController, animated: true, completion: nil)
                return
            }
           
        }
        alterController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alterController.addAction(cancelAction)
        
        self.present(alterController, animated: true, completion: nil)
        
    }
    
    
    func addNewFridgeSetup (name: String) {
        
        let categoryRef = Firestore.firestore().collection("fridges").document()
        let purchaseRef = Firestore.firestore().collection("fridges").document(categoryRef.documentID).collection("awaiting").document()
        
        
        categoryRef.setData([
            "category": ["肉類", "豆類", "雞蛋類", "青菜類", "醃製類", "水果類", "魚類", "海鮮類", "五穀根筋類", "飲料類", "調味料類", "其他"],
            "fridgeID": categoryRef.documentID,
            "fridgeName": name,
            "users": [Auth.auth().currentUser?.email]
        ])
        
        
        
        purchaseRef.setData([
            "id": purchaseRef.documentID,
            "photo": "",
            "name": "按＋新增採購任務",
            "amount": 1,
            "unit": "筆",
            "brand": "輸入推薦品牌",
            "place": "輸入推薦地點",
            "whoBuy": "",
            "note": "右上角按鈕切換任務狀態"
        ])
        
        // 將新增的冰箱ID存起來
        UserDefaults.standard.set(categoryRef.documentID, forKey: .fridgeID)
        
        // 將新建的冰箱ID加到myFridges
        let userDoc = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        userDoc.updateData(["myFridges": Firebase.FieldValue.arrayUnion([categoryRef.documentID])])
    }
    
    func setupWelcome() {
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .autoReverse
        animationView.animationSpeed = 0.5
        animationView.play()
    }
    
}
