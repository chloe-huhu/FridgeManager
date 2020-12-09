//
//  AddFoodTableViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/1.
//

import UIKit
import Firebase
import FirebaseFirestore

class AddFoodTableViewController: UITableViewController {
    
    var foodCategory: [String]?
    
    var food: Foods?
    
    let ref = Firestore.firestore().collection("fridges")
    
    let dataUnit = ["盒", "公克", "公斤", "包", "串", "根"]
    
    var seletedCategoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("🐷🐷🐷🐷🐷🐷🐷🐷🐷🐷🐷🐷🐷🐷🐷🐷")
        print(food)
        dbListenCategory()
    }
    
    @IBOutlet weak var changePicLabel: UILabel! {
        didSet {
            changePicLabel.layer.cornerRadius = 25
            changePicLabel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var foodImageView: UIImageView!
    
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
    
    @IBOutlet weak var amountAlertTextField: RoundedTextField!
    
    @IBOutlet weak var categoryTextField: RoundedTextField! {
        didSet {
            categoryTextField.tag = 4
            categoryTextField.delegate = self
            categoryTextField.inputView = categoryPickerView
        }
    }
    

    @IBAction func categoryBtnTapped(_ sender: UIButton) {
        let alterController = UIAlertController(title: "新增分類", message: nil, preferredStyle: .alert)
        
        alterController.addTextField {(textField) in
            textField.placeholder = "輸入自定義分類"
        }
        
        let okAction = UIAlertAction(title: "新增", style: .default) { (_) in
            let category = alterController.textFields?[0].text
            print(category!)
            self.foodCategory?.append(category!)
           
            //add上去firebase
            self.ref.document("1fK0iw24FWWiGf8f3r0G").updateData(["category": self.foodCategory!])
            
            
        }
        
        alterController.addAction(okAction)
        
        let cancellAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alterController.addAction(cancellAction)
        
        present(alterController, animated: true, completion: nil)
    }
    
    func dbListenCategory() {
        
        ref.document("1fK0iw24FWWiGf8f3r0G").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot
            else {
                print("Error fetching document:\(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty")
                return
            }
            print("======current data:\(data)======")
            self.dbGetCategory()
        }
        
        
    }
    
    func dbGetCategory() {
        
        ref.document("1fK0iw24FWWiGf8f3r0G").getDocument { (document, _) in
            if let document = document, document.exists {
                let data = document.data()
                print(data!)
                self.foodCategory = data?["category"] as? [String]
                print(self.foodCategory!)
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
    

    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBAction func categoryDidSeclected(_ sender: UITextField) {
        categoryTextField.text = foodCategory![seletedCategoryIndex]
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
    
    @IBAction func saveBtnTapped(_ sender: AnyObject) {
        
        if titleTextField.text == "" || amountTextField.text == "" || unitTextField.text == "" || categoryTextField.text == "" || purchaseTextField.text == "" || expiredTextField.text == "" {
            let alterController = UIAlertController(title: "Oops!!", message: "請填好填滿", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
            alterController.addAction(alertAction)
            present(alterController, animated: true, completion: nil)
            return
        }
        
        addListToDB()
        
        //翻回去前一頁
        navigationController?.popViewController(animated: true)

    }
    
  
    func addListToDB() {
        guard let name = titleTextField.text,
              let amount = amountTextField.text,
              let unit = unitTextField.text,
              let category = categoryTextField.text

       
        else { return }
        
        let document =  ref.document("1fK0iw24FWWiGf8f3r0G").collection("foods").document()
        
        let text = amountAlertTextField.text ?? "0"
        
        let amountAlert = Int(text) ?? 0
        
        
        //設定data 內容
        let data: [String: Any] = [
            "id": document.documentID,
            "photo": "test",
            "name": name,
            "amount": Int(amount) ?? 0 ,
            "unit": unit,
            "amountAlert": Int(amountAlert),
            "category": category,
            "purchaseDate": purchaseDatePicker.date,
            "expiredDate": expiredDatePicker.date
        ]
        
        //setData 到firebase
        document.setData(data)
        
    }
    
    func setupFoodDetail() {
        
        if food != nil {
            titleTextField.text = food?.name
        }
    }
    
    func makeFood(_ food: Foods) {
        self.food = food
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 7
    }
    
    //選到第 0 row 開啟相機
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let photoSourceRequestController = UIAlertController(title: "請選擇", message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "拍照", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let photoLibraryAction = UIAlertAction(title: "照片庫", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
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

//從照片庫選擇照片後，從參數選擇被選取的照片
extension AddFoodTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        
        //約束條件
        let leadingConstraint = NSLayoutConstraint(item: photoImageView as Any, attribute: .leading, relatedBy: .equal, toItem: photoImageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: photoImageView as Any, attribute: .trailing, relatedBy: .equal, toItem: photoImageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: photoImageView as Any, attribute: .top, relatedBy: .equal, toItem: photoImageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: photoImageView as Any, attribute: .bottom, relatedBy: .equal, toItem: photoImageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }
}

extension AddFoodTableViewController: UITextFieldDelegate {
    //textfield自動換行
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1 ) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        <#code#>
//    }
}

extension AddFoodTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerView == unitPickerView ? dataUnit.count : foodCategory!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == unitPickerView ? dataUnit[row] : foodCategory![row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == unitPickerView {
            unitTextField.text = dataUnit[row]
        } else {
            categoryTextField.text = foodCategory![row]
            seletedCategoryIndex = row
        }
    }
}
