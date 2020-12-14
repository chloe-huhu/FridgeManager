//
//  AddPurchaseListTableViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/3.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class AddPurchaseListTableViewController: UITableViewController, UITextViewDelegate {
    
    let unit = ["公克", "公斤", "盒", "包", "袋", "隻", "串", "根", "杯", "打"]
    
    var seletedUnitIndex = 0
    
    var downloadURL: String?
    
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
    
    @IBOutlet weak var brandTextField: RoundedTextField! {
        didSet {
            brandTextField.tag = 4
            brandTextField.delegate = self
        }
    }
    @IBOutlet weak var placeTextField: RoundedTextField! {
        didSet {
            placeTextField.tag = 5
            placeTextField.delegate = self
        }
    }
    
    
    @IBOutlet weak var noteTextView: UITextView! {
        didSet {
            noteTextView.tag = 7
            noteTextView.layer.cornerRadius = 5.0
            noteTextView.layer.masksToBounds = true
            noteTextView.text = "豆腐顏色是黃色的"
            noteTextView.textColor = UIColor.lightGray
        }
    }
    
    @IBOutlet var unitPickerView: UIPickerView! {
        didSet {
            unitPickerView.delegate = self
            unitPickerView.dataSource = self
        }
    }
    

    @IBAction func saveBtnTapped(_ sender: Any) {
        if titleTextField.text == "" || amountTextField.text == "" ||
            unitTextField.text == "" || brandTextField.text == "" ||
            placeTextField.text == "" {
            
            let alterController = UIAlertController(title: "Oops!", message: "請填好填滿", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
            
            alterController.addAction(alertAction)
            
            present(alterController, animated: true, completion: nil)
            
            return
        }
        
        addListToDB()
        
        //翻回去前一頁
        navigationController?.popViewController(animated: true)
       
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteTextView.textColor == UIColor.lightGray {
            noteTextView.text = nil
            noteTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
                if noteTextView.text.isEmpty {
                    noteTextView.text = "輸入你想提醒的備註"
                    noteTextView.textColor = UIColor.lightGray
                }
    }
    
    
    func addListToDB() {
        guard let name = titleTextField.text,
              let amount = amountTextField.text,
              let unit = unitTextField.text,
              let brand = brandTextField.text,
              let place = placeTextField.text,
              let note = noteTextView.text,
              let url = downloadURL
        
        else { return }
        
        let ref = Firestore.firestore().collection("fridges").document("1fK0iw24FWWiGf8f3r0G").collection("awaiting")
        
        let document = ref.document()
        
        let data: [String: Any] = [
            "id": document.documentID,
            "photo": url,
            "name": name,
            "amount": Int(amount) ?? 0,
            "unit": unit,
            "brand": brand,
            "place": place,
            "whoBuy": "",
            "note": note
        ]
        
        
        document.setData(data)
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let photoSourceRequestController = UIAlertController(title: "請選擇", message: "拍照或是圖片庫", preferredStyle: .actionSheet)
            
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

extension AddPurchaseListTableViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
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
            
            let storageRef = Storage.storage().reference().child("Food").child("\(uniqueString).png")

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
        //約束條件
//        let leadingConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .leading, relatedBy: .equal, toItem: imageView.superview, attribute: .leading, multiplier: 1, constant: 0)
//        leadingConstraint.isActive = true
//
//        let trailingConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .trailing, relatedBy: .equal, toItem: imageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
//        trailingConstraint.isActive = true
//
//        let topConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .top, relatedBy: .equal, toItem: imageView.superview, attribute: .top, multiplier: 1, constant: 0)
//        topConstraint.isActive = true
//
//        let bottomConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .bottom, relatedBy: .equal, toItem: imageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
//        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }
}

extension AddPurchaseListTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unit.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return unit[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        seletedUnitIndex = row
        unitTextField.text = unit[row]
    }
}

//設定return 跳到下一個文字框
extension AddPurchaseListTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
