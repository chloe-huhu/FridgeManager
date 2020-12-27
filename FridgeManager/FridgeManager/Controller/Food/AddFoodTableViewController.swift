//
//  AddFoodTableViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/1.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Kingfisher
import IQKeyboardManagerSwift

class AddFoodTableViewController: UITableViewController {
    
    var fridgeID: String {
        
        guard let fridgeID = UserDefaults.standard.string(forKey: .fridgeID) else {
            
            return ""
        }
        
        return fridgeID
    }
    
    var ref: CollectionReference {
        
       return Firestore.firestore().collection("fridges").document(fridgeID).collection("foods")
    }
    
    var refCategory: DocumentReference {
        return Firestore.firestore().collection("fridges").document(fridgeID)
    }
    
    var foodCategory: [String]?
    
    var selectedFood: Food? {
        
        didSet {
            
            downloadURL = selectedFood?.photo
        }
    }
    
    let unit = ["公克", "公斤", "盒", "包", "袋", "隻", "串", "根", "杯", "打"]
    
    var seletedCategoryIndex = 0
    
    var seletedUnitIndex = 0
    
    var segueText: List?
    
    var downloadURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbListenCategory()
        setupFoodDetail()
        setupSaveBarBtnItem()
        finishedPurchaseToFoodList()
        self.tabBarController?.tabBar.isHidden = true
    
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleTextField: RoundedTextField! {
        didSet {
            titleTextField.tag = 1
            titleTextField.becomeFirstResponder()
            titleTextField.delegate = self
        }
    }
    
    @IBOutlet weak var amountTextField: RoundedTextField! {
        didSet {
            amountTextField.tag = 2
            amountTextField.delegate = self
        }
    }
    
    @IBOutlet weak var unitTextField: RoundedTextField! {
        didSet {
            unitTextField.tag = 3
            unitTextField.delegate = self
            unitTextField.inputView = unitPickerView
        }
    }
    
    @IBAction func unitDidSeleted(_ sender: UITextField) {
        unitTextField.text = unit[seletedUnitIndex]
    }
    
    
    @IBOutlet weak var categoryTextField: RoundedTextField! {
        didSet {
            categoryTextField.tag = 4
            categoryTextField.delegate = self
            categoryTextField.inputView = categoryPickerView
        }
    }
    
    @IBAction func categoryDidSeclected(_ sender: UITextField) {
        
        categoryTextField.text = foodCategory![seletedCategoryIndex]
    }
    
    @IBAction func categoryBtnTapped(_ sender: UIButton) {
        
        let alterController = UIAlertController(title: "你想對分類做什麼", message: nil, preferredStyle: .actionSheet)
        
        let addCateAction = UIAlertAction(title: "新增分類", style: .default, handler: { _ in
            
            let controller = UIAlertController(title: "輸入欲新增自訂義分類", message: nil, preferredStyle: .alert)
            
            controller.addTextField { (textField) in textField.placeholder = "輸入分類" }
            
            let okAction = UIAlertAction(title: "新增", style: .default) { (_) in
                
                guard let category = controller.textFields?[0].text else { return }
                
                // add上去firebase
                self.refCategory.updateData(["category": FieldValue.arrayUnion(["\(category)"]) ])
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            controller.addAction(okAction)
            
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
            
        })
        
        let deletCateAction = UIAlertAction(title: "刪除分類", style: .default, handler: { _ in
            
            let controller = UIAlertController(title: "輸入欲刪除分類", message: nil, preferredStyle: .alert)
            
            controller.addTextField { (textField) in textField.placeholder = "輸入分類" }
            
            let okAction = UIAlertAction(title: "刪除", style: .default) { (_) in
                
                guard let deleteCategory = controller.textFields?[0].text else { return }
                
                
                // 從firebase delet
                self.ref.document(self.fridgeID).updateData(["category": FieldValue.arrayRemove(["\(deleteCategory)"])])
                
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alterController.addAction(addCateAction)
        alterController.addAction(deletCateAction)
        alterController.addAction(cancelAction)
        
        present(alterController, animated: true, completion: nil)
    }
    
    func dbListenCategory() {
        
        refCategory.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot
            else {
                print("Error fetching document:\(error!)")
                return
            }
            guard document.data() != nil else {
                print("Document data was empty")
                return
            }
            self.dbGetCategory()
        }
        
        
    }
    
    func dbGetCategory() {
        
        refCategory.getDocument { (document, _) in
            if let document = document, document.exists {
                let data = document.data()
                //                    print(data!)
                self.foodCategory = data?["category"] as? [String]
                //                    print(self.foodCategory!)
            } else {
                print("Document does not exist ")
            }
            
        }
    }
    
    @IBOutlet weak var purchaseTextField: RoundedTextField! {
        didSet {
            purchaseTextField.tag = 5
            purchaseTextField.delegate = self
            purchaseTextField.inputView = purchaseDatePicker
            let timeZone = NSTimeZone.local
            let formatter = DateFormatter()
            formatter.timeZone = timeZone
            formatter.dateFormat = "yyyy-MM-dd"
            purchaseTextField.text = formatter.string(from: Date())
            
        }
    }
    
    @IBOutlet weak var expiredTextField: RoundedTextField! {
        didSet {
            expiredTextField.tag = 6
            expiredTextField.delegate = self
            expiredTextField.inputView = expiredDatePicker
        }
    }
    
    
    @IBOutlet var unitPickerView: UIPickerView! {
        didSet {
            unitPickerView.delegate = self
            unitPickerView.dataSource = self
            
        }
    }
    
    @IBOutlet var categoryPickerView: UIPickerView! {
        didSet {
            categoryPickerView.delegate = self
            categoryPickerView.dataSource = self
        }
    }
    
    @IBOutlet var purchaseDatePicker: UIDatePicker! {
        didSet {
            purchaseDatePicker.addTarget(self, action: #selector(purchaseDateSelected), for: .valueChanged)
        }
    }
    
    @IBOutlet var expiredDatePicker: UIDatePicker! {
        didSet {
            expiredDatePicker.addTarget(self, action: #selector(expiredDateSelected), for: .valueChanged)
        }
    }
    
    @objc private func purchaseDateSelected() {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        purchaseTextField.text = formatter.string(from: purchaseDatePicker.date)
    }
    
    @objc private func expiredDateSelected() {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        expiredTextField.text = formatter.string(from: expiredDatePicker.date)
        
    }
    
    func setupSaveBarBtnItem() {
        let img = UIImage(named: "download")
        let rightBtn = UIBarButtonItem(image: img, style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveBtnTapped))
        navigationItem.rightBarButtonItem = rightBtn
    }
    
    
   @objc func saveBtnTapped(_ sender: AnyObject) {
        
        if  titleTextField.text == "" || amountTextField.text == "" || unitTextField.text == "" || categoryTextField.text == "" || purchaseTextField.text == "" || expiredTextField.text == "" {
            let alterController = UIAlertController(title: "Oops!!", message: "請填好填滿", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
            alterController.addAction(alertAction)
            present(alterController, animated: true, completion: nil)
            return
        }
        
        addFoodListToDB()
        
        // 翻回去PurchaseListPage
        self.navigationController?.popToRootViewController(animated: true)
                self.navigationController?.tabBarController?.selectedIndex = 0
        //        self.navigationController?.tabBarController?.tabBarItem
        
    }
    
    
    func addFoodListToDB() {
        
        guard let name = titleTextField.text,
              let amount = amountTextField.text,
              let unit = unitTextField.text,
              let category = categoryTextField.text else { return }
        
              let url = downloadURL == nil ? nil : downloadURL
        
        // 判斷更新食物還是新增食物
        if selectedFood != nil {
            
            guard let id = selectedFood?.id else { return }
            
            ref.document(id).setData([
                "photo": url as Any,
                "name": name,
                "amount": Int(amount) ?? 0 ,
                "unit": unit,
                "category": category,
                "purchaseDate": purchaseDatePicker.date,
                "expiredDate": expiredDatePicker.date
            ], merge: true)
            
        } else {
            
            let id = ref.document().documentID
            
            let data: [String: Any] = [
                "id": id,
                "photo": url as Any,
                "name": name,
                "amount": Int(amount) ?? 0 ,
                "unit": unit,
                "category": category,
                "purchaseDate": purchaseDatePicker.date,
                "expiredDate": expiredDatePicker.date
            ]
            ref.document(id).setData(data)
        }
        
    }
    
    func setupFoodDetail() {
        
        if selectedFood != nil {
            
            self.navigationItem.title = "食物列表"
            
            guard let amount = selectedFood?.amount
            else { return }
            
            if let photo = selectedFood?.photo {
                let foodPhoto = URL(string: photo)
                imageView.kf.setImage(with: foodPhoto, options: [.transition(.fade(0.5))])
                setupImageView(imageView: imageView)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                
            } else {
                imageView.image = UIImage(named: "emptyFood")
                imageView.backgroundColor = .white
                setupImageView(imageView: imageView)
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
            }
            
            titleTextField.text = selectedFood?.name
            amountTextField.text = "\(String(describing: amount))"
            unitTextField.text = selectedFood?.unit
            categoryTextField.text = selectedFood?.category
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            guard let purchseDate = selectedFood?.purchaseDate,
                  let expiredDate = selectedFood?.expiredDate
            else { return }
            
            purchaseTextField.text = dateFormatter.string(from: purchseDate)
            expiredTextField.text = dateFormatter.string(from: expiredDate)
            
        }
        
    }
    func finishedPurchaseToFoodList() {
        
        guard let title = segueText?.name,
              let amount = segueText?.amount,
              let unit = segueText?.unit
        else { return }
        
        titleTextField.text = title
        amountTextField.text = "\(amount)"
        unitTextField.text = unit
        
    }
    
    func setupImageView(imageView: UIImageView) {
        let leadingConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .leading, relatedBy: .equal, toItem: imageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true

        let trailingConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .trailing, relatedBy: .equal, toItem: imageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true

        let topConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .top, relatedBy: .equal, toItem: imageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true

        let bottomConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .bottom, relatedBy: .equal, toItem: imageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }
    
    // 選到第 0 row 開啟相機
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let photoSourceRequestController = UIAlertController(title: "請選擇", message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "拍照", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = true
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let photoLibraryAction = UIAlertAction(title: "照片庫", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = true
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            
            photoSourceRequestController.addAction(cameraAction)
            
            photoSourceRequestController.addAction(photoLibraryAction)
            
            photoSourceRequestController.addAction(cancelAction)
            
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }
    
    
}

// 從照片庫選擇照片後，從參數選擇被選取的照片
extension AddFoodTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[.editedImage] as? UIImage {
            
            selectedImageFromPicker = pickedImage
            
        }
        
        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = NSUUID().uuidString
        
        // 當判斷有 selectedImage 時，我們會在 if 判斷式裡將圖片上傳
        if let selectedImage = selectedImageFromPicker {
            imageView.image = selectedImage
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            let storageRef = Storage.storage().reference().child("food").child("\(uniqueString).png")
            
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
                    }
                })
            }
        }
        setupImageView(imageView: imageView)
        
        dismiss(animated: true, completion: nil)
    }
}

extension AddFoodTableViewController: UITextFieldDelegate {
    // textfield自動換行
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1 ) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}

extension AddFoodTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerView == unitPickerView ? unit.count : foodCategory!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == unitPickerView ? unit[row] : foodCategory![row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == unitPickerView {
            unitTextField.text = unit[row]
            seletedUnitIndex = row
        } else {
            categoryTextField.text = foodCategory![row]
            seletedCategoryIndex = row
        }
    }
}
