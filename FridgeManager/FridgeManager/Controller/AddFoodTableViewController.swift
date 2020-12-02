//
//  AddFoodTableViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/1.
//

import UIKit

class AddFoodTableViewController: UITableViewController {
    
    let dataCategory = ["肉類", "蛋類", "水果類"]
    
    @IBOutlet weak var changePicLabel: UILabel! {
        didSet {
            changePicLabel.layer.cornerRadius = 20
            changePicLabel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var foodImageView: UIImageView!
    
    @IBOutlet weak var foodTitleTextField: RoundedTextField! {
        didSet {
            foodTitleTextField.tag = 1
            foodTitleTextField.becomeFirstResponder()
            foodTitleTextField.delegate = self
        }
    }
    
    @IBOutlet weak var amountTextField: RoundedTextField! {
        didSet {
            amountTextField.tag = 2
            amountTextField.delegate = self
        }
    }
    
    @IBOutlet weak var categoryTextField: RoundedTextField! {
        didSet {
            categoryTextField.tag = 3
            categoryTextField.delegate = self
        }
    }
    
    @IBOutlet weak var purchaseTextField: RoundedTextField! {
        didSet {
            purchaseTextField.tag = 4
            purchaseTextField.delegate = self
        }
    }
    
    @IBOutlet weak var expiredTextField: RoundedTextField! {
        didSet {
            expiredTextField.tag = 5
            expiredTextField.delegate = self
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
    
    @IBOutlet weak var saveBtnItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTextField.inputView = categoryPickerView
        purchaseTextField.inputView = purchaseDatePicker
        expiredTextField.inputView = expiredDatePicker
    }
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBAction func categoryDidSeclected(_ sender: UIButton) {
        //        categoryTextField.text = dataCategory[0]
        //        categoryTextField.text = ""
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
        
        if foodTitleTextField.text == "" || amountTextField.text == "" ||
            categoryTextField.text == "" || purchaseTextField.text == "" ||
            expiredTextField.text == "" {
            
            let alterControloler = UIAlertController(title: "Oops!!", message: "請填好填滿", preferredStyle: .alert)
            let alerAction = UIAlertAction(title: "好", style: .default, handler: nil)
            
            alterControloler.addAction(alerAction)
            
            present(alterControloler, animated: true, completion: nil)
            
            return
        }
        
        print("name:\(foodTitleTextField.text ?? "")")
        print("name:\(amountTextField.text ?? "")")
        print("name:\(categoryTextField.text ?? "")")
        print("name:\(purchaseTextField.text ?? "")")
        print("name:\(expiredTextField.text ?? "")")
        
        dismiss(animated: true, completion: nil)
    }
    
    
    //選到第 0 row 開啟相機
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let photoSourceRequestController = UIAlertController(title: "請選擇", message: "拍照或是圖片", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            photoSourceRequestController.addAction(cameraAction)
            
            photoSourceRequestController.addAction(photoLibraryAction)
            
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
        return dataCategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataCategory[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = dataCategory[row]
    }
}
