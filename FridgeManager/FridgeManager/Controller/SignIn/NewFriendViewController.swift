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

    }

    @IBOutlet weak var animationView: AnimationView!
    
    // 加入現有冰箱-> 提供QRcode->
    @IBAction func joinFridge(_ sender: FancyButton) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let alterController = UIAlertController(title: "請冰箱現有成員掃碼後\n按下確認鍵到冰箱列表查看", message: nil, preferredStyle: .alert)
        
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
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            
            self.performSegue(withIdentifier: "SegueHomeVC", sender: nil)
//            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoVC")
//            
//            viewController.modalPresentationStyle = .fullScreen
//            
//            self.present(viewController, animated: true, completion: nil)
           
        }
        
        alterController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alterController.addAction(cancelAction)
        
        self.present(alterController, animated: true, completion: nil)
        
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
        
        let alterController = UIAlertController(title: "輸入冰箱名稱", message: nil, preferredStyle: .alert)
        
        alterController.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        let okAction = UIAlertAction(title: "新增", style: .default) { (_) in
            
            guard  let fridgeName = alterController.textFields?[0].text else { return }
            
            self.addNewFridgeSetup(name: fridgeName)
            
//            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
//
//            viewController.modalPresentationStyle = .fullScreen
//
//            self.present(viewController, animated: true, completion: nil)
            
            self.performSegue(withIdentifier: "SegueHomeVC", sender: nil)
            
        }
        alterController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alterController.addAction(cancelAction)
        
        self.present(alterController, animated: true, completion: nil)
        
    }
    
    
    func addNewFridgeSetup (name: String) {
        
        let categoryRef = Firestore.firestore().collection("fridges").document()
        
//        let purchaseRef = Firestore.firestore().collection("fridges").document(categoryRef.documentID).collection("awaiting").document()
//        
//        let acceptRef = Firestore.firestore().collection("fridges").document(categoryRef.documentID).collection("accept").document()
        
        categoryRef.setData([
            "category": ["肉類", "豆類", "雞蛋類", "青菜類", "醃製類", "水果類", "魚類", "海鮮類", "五穀根筋類", "飲料類", "調味料類", "其他"],
            "fridgeID": categoryRef.documentID,
            "fridgeName": name,
            "users": [Auth.auth().currentUser?.email]
        ])
//
//        purchaseRef.setData([
//            "id": purchaseRef.documentID,
//            "photo": "https://firebasestorage.googleapis.com/v0/b/fridgemanager-6fd4e.appspot.com/o/purchaseList%2F8F89A6F9-D070-4A29-BCFF-05EC7A4248F6.png?alt=media&token=fd844ac2-4bd7-4161-aa4b-e0ca45528f39",
//            "name": "爸爸喜歡吃的橘子",
//            "amount": 1,
//            "unit": "袋",
//            "brand": "香吉士",
//            "place": "全聯福利中心",
//            "whoBuy": "",
//            "note": "選幾顆比較熟的，最近吃。幾顆比較生的，可以擺久一點"
//        ])
//
//        acceptRef.setData([
//            "id": acceptRef.documentID,
//            "photo": "https://firebasestorage.googleapis.com/v0/b/fridgemanager-6fd4e.appspot.com/o/purchaseList%2F8F89A6F9-D070-4A29-BCFF-05EC7A4248F6.png?alt=media&token=fd844ac2-4bd7-4161-aa4b-e0ca45528f39",
//            "name": "媽媽喜歡的草莓",
//            "amount": 1,
//            "unit": "盒",
//            "brand": "苗栗",
//            "place": "苗栗果園",
//            "whoBuy": "小明",
//            "note": "我跟小美約了週末去採草莓"
//        ])
        
        // 將新增的冰箱ID存起來
        UserDefaults.standard.setValue(categoryRef.documentID, forKey: "FridgeID")
        
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
