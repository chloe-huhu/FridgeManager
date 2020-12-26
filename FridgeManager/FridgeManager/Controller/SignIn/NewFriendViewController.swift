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
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .autoReverse
        animationView.animationSpeed = 0.5
        animationView.play()

    }
    
    @IBOutlet weak var animationView: AnimationView!
    
    @IBAction func joinFridge(_ sender: FancyButton) {
        
        let alterController = UIAlertController(title: "讓擁有冰箱的成員掃碼\n邀請將寄到你的冰箱列表中", message: nil, preferredStyle: .alert)
        
        let qrImageView = UIImageView()
        
        qrImageView.backgroundColor = .red
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        qrImageView.image = self.generateQRCode(from: "\(uid)")
        
        alterController.view.addSubview(qrImageView)
        
        let height = NSLayoutConstraint(item: alterController.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        
        let width = NSLayoutConstraint(item: alterController.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        
        alterController.view.addConstraint(height)
        
        alterController.view.addConstraint(width)
        
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            qrImageView.widthAnchor.constraint(equalToConstant: 100),
            qrImageView.heightAnchor.constraint(equalToConstant: 100),
            qrImageView.centerXAnchor.constraint(equalTo: alterController.view.centerXAnchor),
            qrImageView.centerYAnchor.constraint(equalTo: alterController.view.centerYAnchor)
        ])
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            
            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoVC")
            
            viewController.modalPresentationStyle = .fullScreen
            
            self.present(viewController, animated: true, completion: nil)
           
        }
        
        alterController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alterController.addAction(cancelAction)
        
        self.present(alterController, animated: true, completion: nil)
        
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

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
