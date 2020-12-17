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
        
        guard let id = UserDefaults.standard.value(forKey: "userUid") as? String else {
            
            fatalError("no user id")
        }
        
        return Firestore.firestore().collection("users").document(id)
    }
    
    var fridgesArray: [String] = []
    
    var invitesArray: [String] = []
    
    var downloadURL: String?
    
    var showFridge: ShowFridge = .myFridges
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        dbInfoListen()
    }
    
    @IBOutlet weak var personImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var currentFridge: UILabel!
    
    @IBOutlet weak var myFridgeButton: UIButton!
    
    @IBOutlet weak var fridgeInviteButton: UIButton!
    
    @IBOutlet weak var sliderView: UIView!
    
    
    func btnPressedAnimation(type: ShowFridge) {
        switch showFridge {
        case .myFridges:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.center.x = self.myFridgeButton.center.x
            }
            
        case .myInvites:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.center.x = self.fridgeInviteButton.center.x
            }
            
        }
    }
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
        
        let alterController = UIAlertController(title: "新增冰箱", message: nil, preferredStyle: .alert)
        
        alterController.addTextField { (textField) in
            textField.placeholder = "輸入新冰箱名稱"
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
        
        let doc = Firestore.firestore().collection("fridges").document()
        
        doc.setData([
            "category": ["肉類", "豆類", "雞蛋類", "青菜類", "醃製類", "水果類", "魚類", "海鮮類", "五穀根筋類", "飲料類", "調味料類", "其他"],
            "fridgeID": doc.documentID,
            "fridgeName": name,
            "users": [Auth.auth().currentUser?.email]
        ])
        
        let userDoc = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        
        userDoc.updateData(["myFridges": Firebase.FieldValue.arrayUnion([doc.documentID])])
        
    }
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func editBtnTapped(_ sender: UIButton) {
        
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
            
            self.personImageView.kf.indicatorType = .activity
            
            self.personImageView.kf.setImage(with: userPhoto)
            
        } else {
            
            self.personImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
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
                        
                        for fridge in fridges {
                            self.getFridgeName(fridgeID: fridge)
                        }
                        
                        for invite in invites {
                            self.getInviteName(fridgeID: invite)
                        }
                        
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
    
    func getFridgeName (fridgeID: String) {
        
        fridgesArray = []
        
        Firestore.firestore().collection("fridges").whereField("fridgeID", isEqualTo: fridgeID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documnets : \(error)")
            } else {
                for document in querySnapshot!.documents {
                    //                    print("\(document.documentID) => \(document.data())")
                    
                    do {
                        
                        let data = try document.data(as: Fridge.self)
                        
                        self.fridgesArray.append(data!.fridgeName)
                        
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                    
                }
                //                print("===========", self.fridgesArray)
                self.tableView.reloadData()
            }
            
        }
    }
    
    func getInviteName(fridgeID: String) {
        
        invitesArray = []
        
        Firestore.firestore().collection("fridges").whereField("fridgeID", isEqualTo: fridgeID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documnets : \(error)")
            } else {
                for document in querySnapshot!.documents {
                    //                    print("\(document.documentID) => \(document.data())")
                    
                    do {
                        
                        let data = try document.data(as: Fridge.self)
                        
                        self.invitesArray.append(data!.fridgeName)
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                    
                }
                //                print("===========", self.invitesArray)
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    func switchFridge (fridgeName: String) {
        
        Firestore.firestore().collection("fridges").whereField("fridgeName", isEqualTo: fridgeName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documnets : \(error)")
            } else {
                for document in querySnapshot!.documents {
                    //                    print("=======","\(document.documentID) => \(document.data())")
                    do {
                        
                        let data = try document.data(as: Fridge.self)
                        
//                        data?.fridgeID
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                }
            }
            
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
            switchFridge(fridgeName: selectedFridge)
        case.myInvites:
            let selectedInvite = invitesArray[indexPath.row]
            switchFridge(fridgeName: selectedInvite)
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
