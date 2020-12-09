//
//  InfoViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/6.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class InfoViewController: UIViewController {
    
    let fridgeID = ["9527", "9528"]
    let numberOfPeople = ["共有3位成員", "共有2位成員"]
    var user : [User] = []
    
    @IBOutlet weak var personImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func editBtnTapped(_ sender: UIButton) {
        
        let alterController = UIAlertController(title: "請選擇修改項目", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "更換照片", style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let nameAction = UIAlertAction(title: "更換暱稱", style: .default, handler: { _ in
            
            let controller = UIAlertController(title: "更換暱稱", message: "請輸入新暱稱", preferredStyle: .alert)
            
            controller.addTextField { (textField) in
                textField.placeholder = "暱稱"
            }
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                let name = controller.textFields?[0].text
                print(name!)
                self.nameLabel.text = name
            }
            controller.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alterController.addAction(photoAction)
        alterController.addAction(nameAction)
        alterController.addAction(cancelAction)
        
        present(alterController, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        dbListen()
        dbGet()
    }
    
    func navigationTitleSetup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }
    
    func dbListen() {
        let ref = Firestore.firestore().collection("users").document("qQhDRA4paytTbRGOykM7")
        
        ref.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            print("Current data: \(data)")
//
//            documents.documentChanges.forEach{ diff in
//                if (diff.type == .added) {
//                    print("新增: \(diff.document.data())")
//                    self.tableView.reloadData()
//                }
//                if (diff.type == .modified) {
//                    print("修改: \(diff.document.data())")
//                }
//                if (diff.type == .removed) {
//                    print("刪除: \(diff.document.data())")
//                }
//            }
        }
    }
    
    func dbGet() {
        
        let ref = Firestore.firestore().collection("users").document("qQhDRA4paytTbRGOykM7")
        
        ref.getDocument { (document, err) in
            if let err = err {
                print("Error getting documents:\(err)")
            } else {
                if let document = document, document.exists {
                    print(document.documentID, document.data()!)
                    
                } else {
                    print("Document does not exist")
                }
            }
            
        }
    }
}

extension InfoViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            personImageView.image = selectedImage
            personImageView.contentMode = .scaleAspectFill
            personImageView.clipsToBounds = true
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension InfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let headerLabel = UILabel()
        
        headerLabel.frame = CGRect.init(x: 0, y: 30, width: headerView.frame.width, height: 20)
        headerLabel.text = section == 0 ? "我的冰箱" : "冰箱邀請"
        headerLabel.textColor = UIColor.chloeBlue
        headerLabel.font = UIFont(name: "PingFangTC-Semibold", size: 18)
        headerView.addSubview(headerLabel)
        return headerView
    }
    
}

extension InfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fridgeID.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as? InfoTableViewCell
        else { return UITableViewCell() }
        
        cell.fridgeIDLabel.text = fridgeID [indexPath.row]
        cell.numberOfuserLabel.text = numberOfPeople [indexPath.row]
        
        return cell
    }
    
    
}
