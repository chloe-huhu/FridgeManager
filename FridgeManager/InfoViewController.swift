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
import Kingfisher


class InfoViewController: UIViewController {
    
    let ref = Firestore.firestore().collection("users").document("UUNNN5YELPXtuppYQfluRMKm9Qd2")
    
    
    
    var fridgesIDArray: [String] = []
    
    var inviteArray: [String] = []
    
    var usersArray: [String] = []
    
    var downloadURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        dbListen()
        
    }
    
    @IBOutlet weak var personImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func addNewFridgeBtnTapped(_ sender: UIBarButtonItem) {
        
        let alterController = UIAlertController(title: "新增冰箱", message: "輸入新冰箱名稱", preferredStyle: .alert)
        
        alterController.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        let okAction = UIAlertAction(title: "新增", style: .default) { (_) in
            
            guard  let fridgeName = alterController.textFields?[0].text else { return }
            
            self.addNewFridges(name: fridgeName)
            
        }
        alterController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alterController.addAction(cancelAction)
        
        present(alterController, animated: true, completion: nil)
    }
    
    func addNewFridges (name: String) {
        Firestore.firestore().collection("fridges").document(name).setData([
            "category": ["肉類", "豆類", "雞蛋類", "青菜類", "醃製類", "水果類", "魚類", "海鮮類", "五穀根筋類", "飲料類", "調味料類", "其他"],
            "fridgeID": name
//            "users": Auth.auth().currentUser?.uid
        ])
    }
    
    
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func editBtnTapped(_ sender: UIButton) {
        
        let alterController = UIAlertController(title: "請選擇", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "更換照片", style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
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
    
    @IBAction func myFridge(_ sender: UIButton) {
   
    }
    
    @IBAction func invite(_ sender: UIButton) {
   
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
//                              let email = data?.email,
                              let fridges = data?.fridges,
                              let invites = data?.invites
                             
                        else { return }
                        
                    
                        if let photo = data?.photo {
                            
                            let userPhoto = URL(string: photo)
                            
                            self.personImageView.kf.indicatorType = .activity
                            
                            self.personImageView.kf.setImage(with: userPhoto)
                        }
                        
                        self.nameLabel.text = name
                        
//                        self.emailLabel.text = email
                        
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

extension InfoViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        var selectedImageFromPicker: UIImage?
        
        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[.editedImage] as? UIImage {
            
            selectedImageFromPicker = pickedImage
        }
        
        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = NSUUID().uuidString
        
        if let selectedImage = selectedImageFromPicker {
            personImageView.image = selectedImage
            personImageView.contentMode = .scaleAspectFill
            personImageView.clipsToBounds = true
            
            let storageRef = Storage.storage().reference().child("users").child("\(uniqueString).png")
            if let uploadData = selectedImage.pngData() {
                
                // 這行就是 FirebaseStorage 關鍵的存取方法。
                storageRef.putData(uploadData, metadata: nil, completion: { (data, error) in
                    
                    if error != nil {
                        
                        // 若有接收到錯誤，我們就直接印在 Console 就好，在這邊就不另外做處理。
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        
                        if let error = error {
                            
                            print(error)
                        }
                        guard let downloadURL = url else { return }
                        
                        print("Photo Url: \(downloadURL)")
                        
                        self.downloadURL = "\(downloadURL)"
                        self.updateUserPhoto()
                    }
                })
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func updateUserPhoto() {
        
        guard let photo = downloadURL else { return }
        
        ref.updateData(["photo": photo])
        
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
            
//            cell.numberOfuserLabel.text = numberOfPeople [indexPath.row]
            
        } else {
            
            cell.fridgeIDLabel.text = inviteArray[indexPath.row]
            
//            cell.numberOfuserLabel.text = numberOfPeople [indexPath.row]
            
        }
       
        return cell
    }
    
    
}
