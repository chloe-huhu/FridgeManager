//
//  InfoViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/6.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwiftg


class InfoViewController: UIViewController {
    
    let numberOfPeople = ["共有3位成員", "共有2位成員"]
    
    let ref = Firestore.firestore().collection("users").document("UUNNN5YELPXtuppYQfluRMKm9Qd2")
    
    
//    var userTest = [String: Any]()
    
    var fridgesIDArray: [String] = []
    
    var inviteArray: [String] = []
    
    var usersArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        dbListen()
        
    }
    
    @IBOutlet weak var personImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func editBtnTapped(_ sender: UIButton) {
        
        let alterController = UIAlertController(title: "請選擇", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "更換照片", style: .default, handler: { (_) in
//            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//                let imagePicker = UIImagePickerController()
//                imagePicker.allowsEditing = false
//                imagePicker.sourceType = .photoLibrary
//                imagePicker.delegate = self
//                self.present(imagePicker, animated: true, completion: nil)
//            }
            
//            let imagePickerController = ImagePickerController()
//                imagePickerController.delegate = self
//                imagePickerController.imageLimit = 1
//
//                self.present(imagePickerController, animated: true, completion: nil)
//
        })
        
        let nameAction = UIAlertAction(title: "更換暱稱", style: .default, handler: { _ in
            
            let controller = UIAlertController(title: "更換暱稱", message: "請輸入新暱稱", preferredStyle: .alert)
            
            controller.addTextField { (textField) in
                textField.placeholder = "暱稱"
            }
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                
                guard let name = controller.textFields?[0].text else { return }
                
                self.ref.updateData(["name": name])
                
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
    
    func navigationTitleSetup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }
    
    func dbListen() {
        
        ref.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard document.data() != nil else {
                print("Document data was empty.")
                return
            }
            self.dbGet()
        }
    }
    
    func dbGet() {
        
        ref.getDocument { (document, err) in
            if let err = err {
                print("Error getting documents:\(err)")
            } else {
                
                if let document = document, document.exists {
                    do {
                        
                        let data = try document.data(as: User.self)
                        
                        guard let name = data?.name,
                              let email = data?.email,
                              let fridges = data?.fridges,
                              let invites = data?.invites
                        
                        else { return }
                        
                        // self.personImageView.image = UIImage(named: user!.photo)
                        
                        self.nameLabel.text = name
                        
                        self.emailLabel.text = email
                        
                        self.fridgesIDArray = fridges
                        
                        self.inviteArray = invites
                        
                    } catch {
                        print("error to decode", error)
                    }
                    
                } else {
                    print("Document does not exist")
                }
                
                self.tableView.reloadData()
            }
            
        }
    }
    
    

    
}

//extension InfoViewController: ImagePickerDelegate {
//
//    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//
//    }
//
//    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        guard let image = images.first else {
//            dismiss(animated: true, completion: nil)
//            return
//        }
//
//        let imageStorageRef = Storage.storage().reference().child("photos").child("\(imageKey).jpg")
//
//            // 調整圖片大小
//            let scaledImage = image.scale(newWidth: 640.0)
//
//            guard let imageData = scaledImage.jpegData(compressionQuality: 0.9) else {
//                dismiss(animated: true, completion: nil)
//
//                return
//            }
//            // 建立檔案的元資料
//            let metadata = StorageMetadata()
//            metadata.contentType = "image/jpg"
//
//            // 上傳任務準備
//            let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
//
//            // 觀察上傳狀態
//            uploadTask.observe(.success) { (snapshot) in
//
//                guard let displayName = Auth.auth().currentUser?.displayName else {
//                    return
//                }
//
//                snapshot.reference.downloadURL(completion: { (url, error) in
//                    guard let url = url else {
//                        return
//                    }
//
//                    // 在資料庫加上一個參照
//                    let imageFileURL = url.absoluteString
//                    let timestamp = Int(Date().timeIntervalSince1970 * 1000)
//
//                    let post: [String : Any] = ["imageFileURL" : imageFileURL,
//                                                "votes" : Int(0),
//                                                "user" : displayName,
//                                                "timestamp" : timestamp
//                                                ]
//
//                    postDatabaseRef.setValue(post)
//
//                })
//
//
//                self.dismiss(animated: true, completion: nil)
//            }
//
//            uploadTask.observe(.progress) { (snapshot) in
//
//                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
//                print("Uploading \(imageKey).jpg... \(percentComplete)% complete")
//            }
//
//
//            uploadTask.observe(.failure) { (snapshot) in
//
//                if let error = snapshot.error {
//                    print(error.localizedDescription)
//                }
//            }
//        }
//
//    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//}
//extension InfoViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//
//        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            personImageView.image = selectedImage
//            personImageView.contentMode = .scaleAspectFill
//            personImageView.clipsToBounds = true
//        }
//
//        dismiss(animated: true, completion: nil)
//    }
//}

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
       
        if section == 0 {
            return fridgesIDArray.count
        } else {
            return inviteArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as? InfoTableViewCell else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            
            cell.fridgeIDLabel.text = fridgesIDArray[indexPath.row]
            
            cell.numberOfuserLabel.text = numberOfPeople [indexPath.row]
            
        } else {
            
            cell.fridgeIDLabel.text = inviteArray[indexPath.row]
            
            cell.numberOfuserLabel.text = numberOfPeople [indexPath.row]
            
        }
       
        return cell
    }
    
    
}
