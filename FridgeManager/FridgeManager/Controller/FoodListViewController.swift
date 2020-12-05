//
//  FoodListViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/25.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import ExpandingMenu

class FoodListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                textfield.backgroundColor = .white
            }
        }
    }
    
    var foods: [Foods] = []
    
    let sectionDataList: [String] = ["肉類", "雞蛋類", "青菜類", "水果類", "魚類", "五穀根筋類", "飲料類", "其他" ]
    
    let sectionImage: [String] = ["cabbage", "avocado", "boiled", "bread-2", "bread-1", "bread", "bread", "bread", "bread", "bread", "bread"]
    
    let sectionDataAmount: [String] = ["總計有3筆", "總計有4筆", "總計有6筆", "總計有7筆", "總計有7筆", "總計有7筆", "總計有8位", "總計有8位", "總計有8位" ]
    
    let sectionDataDate: [String] = ["2020-09-24", "2020-09-24", "2020-09-24", "2020-09-24", "2020-09-24", "2020-09-24", "2020-09-24", "2020-09-24", "2020-09-24" ]
    
    let rowDataList: [[String]] = [["Costco牛排", "全聯火鍋片", "豬絞肉"],
                                   ["土雞蛋", "鵪鶉蛋", "溫泉蛋", "有雞蛋", "皮蛋"]]
    
    let rowDataAmount: [[String]] = [["數量：1000 公克", "數量：200 公克", "數量：200 公克"],
                                     ["數量：200 公克", "數量：200 公克", "數量：200 公克", "數量：200 公克", "數量：200 公克"]]
    
    
    var isExpendDataList: [Bool] = [false, false, false, false, false, false, false, false, false]
    
    let searchButton = UIButton()
    
    var showCategory: ShowCategory = .all
    
    let takingPicture = UIImagePickerController()
    
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    
    @IBOutlet weak var fliterBarButton: UIBarButtonItem!
    
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var soonExpiredButton: UIButton!
    @IBOutlet weak var expiredButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    
    @IBOutlet weak var addContentButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            let sectionViewNib: UINib = UINib(nibName: "SectionView", bundle: nil)
            self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "SectionView")
            
            let cellViewNib: UINib = UINib(nibName: "CellView", bundle: nil)
            self.tableView.register(cellViewNib, forCellReuseIdentifier: "CellView")
        }
    }
    
    var database: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        tabBarSetup()
        expandingMenuButton()
        dbListen()
        dbGet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    func dbListen() {
        
        let ref = Firestore.firestore().collection("fridges").document("1fK0iw24FWWiGf8f3r0G").collection("foods")
        
        FirebaseManager.shared.listen(ref: ref) {
            
            
        }
    }
    
    func dbGet() {
        
        let ref = Firestore.firestore().collectionGroup("foods")
        
        ref.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("現有的資料 \(document.documentID) => \(document.data())")
                    do {
                        
                        let data = try document.data(as: Foods.self)
                        
                        self.foods.append(data!)
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                    
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    func navigationTitleSetup() {
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.view.backgroundColor = .chloeYellow
    }
    
    func tabBarSetup() {
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
    
    @IBAction func allPressed(_ sender: UIButton) {
        showCategory = .all
        btnPressedAnimation(type: .all)
    }
    
    @IBAction func soonExpiredPressed(_ sender: UIButton) {
        showCategory = .soonExpired
        btnPressedAnimation(type: .soonExpired)
        
    }
    
    @IBAction func expiredPressed(_ sender: UIButton) {
        showCategory = .expired
        btnPressedAnimation(type: .expired)
        
    }
    
    func btnPressedAnimation(type: ShowCategory) {
        
        switch showCategory {
        case .all:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = 6
            }
            
        case .soonExpired:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = ((self.view.frame.width)/3)+6
            }
        case .expired:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = ((self.view.frame.width)/3*2)+6
            }
        }
    }
    
    func getCategoryTitle(_ title: String) -> [Foods] {
        
        var foodList: [Foods] = []
        
        for food in foods {
            
            if food.category == title {
                
                foodList.append(food)
            }
        }
        
        return foodList
    }
}

//老唐寫的掃描發票
extension FoodListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            
        }
        
        takingPicture.dismiss(animated: true, completion: nil)
    }
}

extension FoodListViewController: UITableViewDelegate {
    
    // header高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    // footer高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    // row高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "SegueFoodDetail", sender: nil)
    }
    // section content
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionView: SectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionView") as? SectionView
        else { return UIView() }
        
        //        sectionView.isExpand = self.isExpendDataList[section]
        //        sectionView.buttonTag = section
        //        sectionView.delegate = self
        //
        //        sectionView.foodImage.image = UIImage(named: self.sectionImage[section])
        //        sectionView.foodTitleLabel.text = foods[section].name
        //        sectionView.foodAmountLabel.text = "\(foods[section].amount)"
        
        return sectionView
    }
    
}

extension FoodListViewController: UITableViewDataSource {
    // section 數量
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDataList.count
    }
    // row 數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return getCategoryTitle(sectionDataList[section]).count
    }
    // row content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell: CellView = tableView.dequeueReusableCell(withIdentifier: "CellView", for: indexPath) as? CellView
       
        else { return UITableViewCell() }
        
        let foods = getCategoryTitle(sectionDataList[indexPath.section])
        
        cell.setup(data: foods[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //409頁
    }
    
}

extension FoodListViewController: SectionViewDelegate {
    
    func sectionView(_ sectionView: SectionView, _ didPressTag: Int, _ isExpand: Bool) {
        self.isExpendDataList[didPressTag] = !isExpand
        self.tableView.reloadSections(IndexSet(integer: didPressTag), with: .automatic)
    }
    
}

//第三方套件

extension FoodListViewController {
    
    func expandingMenuButton() {
        let btnSize: CGSize = CGSize(width: 100.0, height: 100.0)
        let xAxis = self.view.bounds.width
        let yAxis = self.view.bounds.height
        let origin = CGPoint.zero
        let image = #imageLiteral(resourceName: "add")
        let rotated = #imageLiteral(resourceName: "add")
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: origin, size: btnSize), image: image, rotatedImage: rotated)
        
        menuButton.center = CGPoint(x: xAxis-50, y: yAxis-200)
        self.view.addSubview(menuButton)
        
        func showAlert(_ title: String) {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let imageItem1 = UIImage(named: "type")
        let item1 = ExpandingMenuItem(size: btnSize, title: "手動輸入",
                                      image: imageItem1!,
                                      highlightedImage: imageItem1,
                                      backgroundImage: imageItem1,
                                      backgroundHighlightedImage: imageItem1) {
            self.performSegue(withIdentifier: "SegueAddContent", sender: self)
        }
        
        let imageItem2 = UIImage(named: "photo")
        let item2 = ExpandingMenuItem(size: btnSize, title: "掃描發票",
                                      image: imageItem2!,
                                      highlightedImage: imageItem2,
                                      backgroundImage: imageItem2,
                                      backgroundHighlightedImage: imageItem2) {
            
            self.takingPicture.sourceType = .camera
            
            self.takingPicture.allowsEditing = false
            
            self.takingPicture.delegate = self
            
            self.present(self.takingPicture, animated: true, completion: nil)
        }
        
        menuButton.addMenuItems([item1, item2])
        
        menuButton.willPresentMenuItems = { (_) -> Void in
            print("MenuItems will present.")
        }
        
        menuButton.didDismissMenuItems = { (_) -> Void in
            print("MenuItems dismissed.")
        }
        
    }
    
}
