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
    
    
    
    var refUID: DocumentReference? {
        
        guard let userUid = UserDefaults.standard.value(forKey: "userUid") as? String else {
            
            fatalError("no user id")
        }
        
        return Firestore.firestore().collection("users").document(userUid)
    }
    
    var fridgesArray: [String] = []
    
    var invitesArray: [String] = []
    
    var downloadURL: String?

    var invitedFriend: String?
    
    var currentFridgeID: String? {
        
        get {
        
            guard let currentFridgeID = UserDefaults.standard.string(forKey: .fridgeID) else { return "" }
        
            return currentFridgeID
        }
        
        set { }
    }
            
    
    var showFridge: ShowFridge = .myFridges
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        dbInfoListen()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBOutlet weak var personImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var currentFridge: LabelPadding! {
        didSet {
            guard let fridgeID = UserDefaults.standard.value(forKey: .fridgeID) as? String else { return }
            changeFridgeName(fridgeID: fridgeID)
        }
    }
    
    func changeFridgeName(fridgeID: String) {
        
        Firestore.firestore().collection("fridges").whereField("fridgeID", isEqualTo: fridgeID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documnets : \(error)")
            } else {
                for document in querySnapshot!.documents {
                    
                    do {
                        
                        let data = try document.data(as: Fridge.self)
                        
                        self.currentFridge.text = data?.fridgeName
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                    
                }
                
            }
            
        }
    }
    
    @IBOutlet weak var fridgeListButton: UIButton!
    
    @IBOutlet weak var fridgeInvitedButton: UIButton!
    
    @IBOutlet weak var sliderView: UIView!
    
    
    @IBAction func myFridgesBtnTapped(_ sender: UIButton) {
        showFridge = .myFridges
        btnPressedAnimation(type: .myFridges)
        tableView.reloadData()
    }
    
    @IBAction func fridgeInviteBtnTapped (_ sender: UIButton) {
        showFridge = .myInvites
        btnPressedAnimation(type: .myInvites)
        tableView.reloadData()
    }
    
    @IBAction func addNewFridgeBtnTapped(_ sender: UIBarButtonItem) {
        
        let controller = UIAlertController(title: "請選擇", message: nil, preferredStyle: .actionSheet)
        
        let addFridgeAction = UIAlertAction(title: "建立新冰箱", style: .default, handler: { _ in
            let alterController = UIAlertController(title: "輸入冰箱名稱", message: nil, preferredStyle: .alert)
            
            alterController.addTextField { (textField) in
                textField.placeholder = ""
            }
            
            let okAction = UIAlertAction(title: "新增", style: .default) { (_) in
                
                guard  let fridgeName = alterController.textFields?[0].text else { return }
                
                self.addNewFridgeSetup(name: fridgeName)
                
            }
            alterController.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alterController.addAction(cancelAction)
            
            self.present(alterController, animated: true, completion: nil)
            
        })
        
        guard let currentFridgeName = currentFridge.text else { return }
        
        let addMemberAction = UIAlertAction(title: "邀請成員加入\(currentFridgeName)", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "segueQRCodeCamera", sender: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        controller.addAction(addFridgeAction)
        controller.addAction(addMemberAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueQRCodeCamera" {
            
            let destVC = segue.destination as? QRCodeViewController
            
            destVC?.delegate = self
        }
    }
    
    func addNewFridgeSetup (name: String) {
        
        let categoryRef = Firestore.firestore().collection("fridges").document()
        
        // 直接設定分類、冰箱名稱、把創建人加進去冰箱 users
        categoryRef.setData([
            "category": ["肉類", "豆類", "雞蛋類", "青菜類", "醃製類", "水果類", "魚類", "海鮮類", "五穀根筋類", "飲料類", "調味料類", "其他"],
            "fridgeID": categoryRef.documentID,
            "fridgeName": name,
            "users": [Auth.auth().currentUser?.email]
        ])
    
        // 將新建的冰箱ID加到myFridges
        let userDoc = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        userDoc.updateData(["myFridges": Firebase.FieldValue.arrayUnion([categoryRef.documentID])])
        
    }

    @IBOutlet weak var editPersonInfoBarBtn: UIBarButtonItem!
    
    @IBAction func editPersonInfoBtnTapped(_ sender: UIBarButtonItem) {
        
        let alterController = UIAlertController(title: "更換個人設定", message: nil, preferredStyle: .actionSheet)
        
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
            
            let controller = UIAlertController(title: "輸入新暱稱", message: nil, preferredStyle: .alert)
            
            controller.addTextField { (textField) in
                textField.placeholder = "暱稱"
            }
            
            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                
                guard let name = controller.textFields?[0].text else { return }
                
                self.refUID!.updateData(["displayName": name])
                
                self.nameLabel.text = name
                
            }
            
            controller.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
        })
        
        
        let qrCodeAction = UIAlertAction(title: "我的 QR Code", style: .default, handler: { _ in
        
            let controller = UIAlertController(title: "讓擁有冰箱的成員掃碼\n邀請匯寄到你的冰箱列表中", message: nil, preferredStyle: .alert)
            
            let qrImageView = UIImageView()
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            qrImageView.image = self.generateQRCode(from: "\(uid)")
            
            controller.view.addSubview(qrImageView)
            
            let height = NSLayoutConstraint(item: controller.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
            
            let width = NSLayoutConstraint(item: controller.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
            
            controller.view.addConstraint(height)
            
            controller.view.addConstraint(width)
            
            qrImageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                qrImageView.widthAnchor.constraint(equalToConstant: 150),
                qrImageView.heightAnchor.constraint(equalToConstant: 150),
                qrImageView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
                qrImageView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
            ])
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
        })
        
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alterController.addAction(photoAction)
        alterController.addAction(nameAction)
        alterController.addAction(cancelAction)
        alterController.addAction(qrCodeAction)
        
        present(alterController, animated: true, completion: nil)
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
    
    func dbInfoListen() {
        
        refUID!.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard document.data() != nil else {
                print("Document data was empty.")
                return
            }
            
            self.dbInfoGet()
        }
    }
    
    private func setupPhoto(_ photo: String) {
        if photo != "" {
            
            let userPhoto = URL(string: photo)
            
            self.personImageView.kf.setImage(with: userPhoto, options: [.transition(.fade(0.5))])
            
            personImageView.contentMode = .scaleAspectFill
            
            personImageView.clipsToBounds = true
            
        } else {
            
            self.personImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
    
    // 監聽個人頁面(photo\displayName\冰箱列表\冰箱邀請)
    func dbInfoGet() {
        
        refUID!.getDocument { (document, err) in
            if let err = err {
                print("Error getting documents:\(err)")
            } else {
                
                if let document = document, document.exists {
                    do {
                        
                        let data = try document.data(as: User.self)
                        
                        guard let name = data?.displayName,
                              let fridges = data?.myFridges,
                              let invites = data?.myInvites,
                              let photo = data?.photo
                        
                        else { return }
                        
                        self.setupPhoto(photo)
                        
                        self.nameLabel.text = name
                        
                        self.fridgesArray = []
                        
                        for fridge in fridges {
                            self.getFridgeName(fridgeID: fridge)
                        }
                        
                        self.invitesArray = []
                        
                        for invite in invites {
                            self.getInviteName(fridgeID: invite)
                        }
                        
                        self.tableView.reloadData()
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                    
                } else {
                    
                    print("Document does not exist")
                }
            }
        }
    }
    
    // 冰箱列表
    func getFridgeName (fridgeID: String) {
        
        Firestore.firestore().collection("fridges").whereField("fridgeID", isEqualTo: fridgeID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documnets : \(error)")
            } else {
            
                for document in querySnapshot!.documents {
                    
                    do {
                        
                        let data = try document.data(as: Fridge.self)
                        
                        if (!self.fridgesArray.contains(data!.fridgeName)) {
                            self.fridgesArray.append(data!.fridgeName)
                        }
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                    
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    //  冰箱邀請
    
    func getInviteName(fridgeID: String) {
        
        Firestore.firestore().collection("fridges").whereField("fridgeID", isEqualTo: fridgeID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documnets : \(error)")
            } else {
                for document in querySnapshot!.documents {

                    do {
                        
                        let data = try document.data(as: Fridge.self)
                        
                        if (!self.invitesArray.contains(data!.fridgeName)) {
                            self.invitesArray.append(data!.fridgeName)
                        }
                       
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                    
                }
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    // 切換冰箱
    func switchFridge (fridgeName: String) {
        
        Firestore.firestore().collection("fridges").whereField("fridgeName", isEqualTo: fridgeName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documnets : \(error)")
            } else {
                for document in querySnapshot!.documents {

                    do {
                        
                        let data = try document.data(as: Fridge.self)
                        
                        self.currentFridgeID = data?.fridgeID
                        
                        UserDefaults.standard.setValue(data?.fridgeID, forKey: "FridgeID")
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                }
            }
            
        }
        
    }
    
    func findFridgeID(fridgeName: String) {
        
        Firestore.firestore().collection("fridges").whereField("fridgeName", isEqualTo: fridgeName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documnets : \(error)")
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let data = try document.data(as: Fridge.self)
                        
                        let fridgeID = data?.fridgeID
                        
                        deleteMyFridge(fridgeID: fridgeID!)
                        
                    } catch {
                        print("error to decode", error)
                    }
                }
            }
            
        }
        
        func deleteMyFridge(fridgeID:String) {
            let uid = Auth.auth().currentUser!.uid
            Firestore.firestore().collection("users").document(uid).updateData(["myFridges": FieldValue.arrayRemove([fridgeID])])
        }

        
    }
    
    func btnPressedAnimation(type: ShowFridge) {
        switch showFridge {
        case .myFridges:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.center.x = self.fridgeListButton.center.x
            }
            
        case .myInvites:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.center.x = self.fridgeInvitedButton.center.x
            }
            
        }
    }
    
    func fridgePopUp(fridgeName: String) {
        
        switch showFridge {
        
        case .myFridges:
            
            let alterController = UIAlertController(title: "請選擇", message: nil, preferredStyle: .actionSheet)
            
            let switchFridge = UIAlertAction(title: "切換冰箱", style: .default, handler: {_ in
                
                let controller = UIAlertController(title: "切換冰箱至", message: "\(fridgeName)冰箱", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "確定", style: .default, handler: { _ in
                    
                    self.currentFridge.text = fridgeName
                    
                    self.switchFridge(fridgeName: fridgeName)
                })
                
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                
                controller.addAction(okAction)
                
                controller.addAction(cancelAction)
                
                self.present(controller, animated: true, completion: nil)
            
            })
              
            if fridgesArray.count == 1 {
                let deleteFridge = UIAlertAction(title: "退出冰箱", style: .default, handler: {_ in
                    
                    let controller = UIAlertController(title: "只剩一個冰箱，不能再退出摟！", message: nil, preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    
                    controller.addAction(cancelAction)
                    
                    self.present(controller, animated: true, completion: nil)
                    
                })
                alterController.addAction(deleteFridge)
                
            } else {
                let deleteFridge = UIAlertAction(title: "退出冰箱", style: .default, handler: {_ in
                    
                    let controller = UIAlertController(title: "退出冰箱", message: "\(fridgeName)冰箱", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "確定", style: .default, handler: { _ in
                        
                        self.findFridgeID(fridgeName: fridgeName)
                        
                    })
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    
                    controller.addAction(okAction)
                    
                    controller.addAction(cancelAction)
                    
                    self.present(controller, animated: true, completion: nil)
                    
                })
                alterController.addAction(deleteFridge)
                
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler:nil)
            
            alterController.addAction(switchFridge)
           
            alterController.addAction(cancelAction)
            
            present(alterController, animated: true, completion: nil)
   
        case.myInvites:
            
            let controller = UIAlertController(title: "接受邀請", message: "加入\(fridgeName)冰箱", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "確定", style: .default, handler: { _ in
                
                Firestore.firestore().collection("fridges").whereField("fridgeName", isEqualTo: fridgeName).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documnets : \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            
                            print("=======", "\(document.documentID) => \(document.data())")
                            
                            do {
                                
                                let data = try document.data(as: Fridge.self)
                                
                                guard let fridgeID = data?.fridgeID else { return }
                                
                                // 把接受的冰箱ID加入到user的myFridgeListArray裡面
                                
                                let userDoc = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
                                
                                userDoc.updateData(["myFridges": Firebase.FieldValue.arrayUnion([fridgeID])])
                                
                                // 刪除InviteListArray
                                userDoc.updateData(["myInvites": Firebase.FieldValue.arrayRemove([fridgeID])])
                                
                            } catch {
                                
                                print("error to decode", error)
                            }
                        }
                    }
                    
                }
            
                
            })
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            controller.addAction(okAction)
            
            controller.addAction(cancelAction)
            
            present(controller, animated: true, completion: nil)
        }
    }
    
}

extension InfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch showFridge {
        
        case .myFridges:
            let selectedFridge = fridgesArray[indexPath.row]
                fridgePopUp(fridgeName: selectedFridge)

        case.myInvites:
            let selectedInvite = invitesArray[indexPath.row]
            fridgePopUp(fridgeName: selectedInvite)
        }
    }
    
}

extension InfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch showFridge {
        
        case .myFridges:
            return fridgesArray.count
        case .myInvites:
            return invitesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as? InfoTableViewCell else { return UITableViewCell() }
        
        switch showFridge {
        
        case .myFridges:
            cell.fridgeIDLabel.text = fridgesArray[indexPath.row]
            
        case .myInvites:
            cell.fridgeIDLabel.text = invitesArray [indexPath.row]
        }
        
        return cell
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
                        
                        //                        print("Photo Url: \(downloadURL)")
                        
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
        
        refUID!.updateData(["photo": photo])
        
    }
}

extension InfoViewController: qRCodeDelegate {
    
    func sendInite(userUID: String) {
        
        let doc = Firestore.firestore().collection("users").document(userUID)
        
        guard let currentFridgeID = currentFridgeID else { return }
        
        doc.updateData(["myInvites": Firebase.FieldValue.arrayUnion([currentFridgeID])])
        
        print("邀請\(userUID)入群")
        
    }
    
}
