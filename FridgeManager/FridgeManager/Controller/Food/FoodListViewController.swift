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
    
    let ref = Firestore.firestore().collection("fridges").document("1fK0iw24FWWiGf8f3r0G").collection("foods")
    
    var sectionImage: [String: String] = ["肉類": "turkey", "豆類": "beans", "雞蛋類": "eggs", "青菜類": "cabbage", "醃製類": "bacon", "水果類": "blueberries", "魚類": "fish", "海鮮類": "shrimp", "五穀根筋類": "grain", "飲料類": "coffee-3", "調味料類": "flour-1", "其他": "groceries"]
    
    var oriFoods: [Food] = []
    
    var foodsDic: [String: [Food]] = [:]
    
    var foodsKeyArray: [String] = []
    
    var isExpendDataList: [Bool] = []
    
    var selectedFood: Food?
    
    var showCategory: ShowCategory = .all
    
    let searchButton = UIButton()
    
    let takingPicture = UIImagePickerController()
    
    var showType: ShowType = .edit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleSetup()
        tabBarSetup()
        expandingMenuButton()
        dbListen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) { selectedData() }
    
    func selectedData() {
        switch showType {
        case .edit:
            editButton.image = #imageLiteral(resourceName: "close")
            tableView.isEditing = !tableView.isEditing
            isExpendDataList = isExpendDataList.map { _ in return true }
            tableView.reloadData()
            showType = .delete

        case .delete:
            editButton.image = #imageLiteral(resourceName: "folder.png")
            showType = .edit
            deleteRows()
            tableView.isEditing = !tableView.isEditing
            tableView.reloadData()
        }
        
    }
    
    func deleteRows() {
        if let seletedRows = tableView.indexPathsForSelectedRows {
            var selectedItems: [Food] = []
            for indexPath in seletedRows {
                selectedItems.append(foodsDic[foodsKeyArray[indexPath.section]]![indexPath.row])
            }
            for selecteditem in selectedItems {
                ref.document(selecteditem.id).delete()
            }
        }
    }
    
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    
    @IBOutlet weak var allBtn: UIButton!
    
    @IBOutlet weak var soonExpiredBtn: UIButton!
    
    @IBOutlet weak var expiredBtn: UIButton!
    
    @IBOutlet weak var sliderView: UIView!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.allowsMultipleSelection = true
            tableView.allowsMultipleSelectionDuringEditing = true
            
            let sectionViewNib: UINib = UINib(nibName: "SectionView", bundle: nil)
            self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "SectionView")
            
            let cellViewNib: UINib = UINib(nibName: "CellView", bundle: nil)
            self.tableView.register(cellViewNib, forCellReuseIdentifier: "CellView")
        }
    }
    
    @IBAction func allPressed(_ sender: UIButton) {
        showCategory = .all
        
        btnPressedAnimation(type: .all)
        
        reloadDataForFoods(foods: oriFoods)
    }
    
    @IBAction func soonExpiredPressed(_ sender: UIButton) {
        showCategory = .soonExpired
        
        btnPressedAnimation(type: .soonExpired)
        
        let midnight = getMidnightTime()
        
        let soonExpiredFoods = oriFoods.filter {
            $0.expiredDate.timeIntervalSince1970 > midnight
                && $0.expiredDate.timeIntervalSince1970 < midnight + 86400 * 3
        }
        
        reloadDataForFoods(foods: soonExpiredFoods)
    }
    
    @IBAction func expiredPressed(_ sender: UIButton) {
        showCategory = .expired
        
        btnPressedAnimation(type: .expired)
        
        let midnight = getMidnightTime()
        
        let expiredFoods = oriFoods.filter {
            $0.expiredDate.timeIntervalSince1970 < midnight
        }
        
        reloadDataForFoods(foods: expiredFoods)
        
    }
    
    func dbListen() {
        
        FirebaseManager.shared.listen(ref: ref) {
            
            self.dbGet()
        }
    }
    
    func dbGet() {
        
        ref.getDocuments { (querySnapshot, err) in
            
            if let err = err {
                
                print("Error getting documents: \(err)")
                
            } else {
                
                self.oriFoods = []
                
                for document in querySnapshot!.documents {
                    
                    //print("現有的資料 \(document.documentID) => \(document.data())")
                    
                    do {
                        //獲得某食材的資料
                        let food = try document.data(as: Food.self)
                        
                        self.oriFoods.append(food!)
                        
                    } catch {
                        
                        print("error to decode", error)
                    }
                    
                }
                
                self.reloadDataForFoods(foods: self.oriFoods)
            }
            
        }
    }
    
    func reloadDataForFoods(foods: [Food]) {
        
        foodsDic = [:]
        
        foodsKeyArray = []
        
        for food in foods {
            //產生key(Section)
            if foodsDic[food.category] == nil {
                //print("---- category is not in dictionary")
                self.foodsDic[food.category] = []
                self.isExpendDataList.append(false)
            }
            
            //在key底下,新增value (Section:data1\data2)
            self.foodsDic[food.category]?.append(food)
        }
        
        self.foodsKeyArray = Array(self.foodsDic.keys.sorted())
        
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //有兩個perform segue，共用一個prepare，去分辨點選哪一個
        let destVC = segue.destination as? AddFoodTableViewController
        destVC?.selectedFood =  segue.identifier == "SegueAddContent" ? nil : selectedFood
    }
    
    func getMidnightTime() -> TimeInterval {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let today = Date()
        let midnight = calendar.startOfDay(for: today)
        return midnight.timeIntervalSince1970
    }
    
    func btnPressedAnimation(type: ShowCategory) {
        
        switch showCategory {
        case .all:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = 6
            }
            
        case .soonExpired:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = ((self.view.frame.width)/3)
            }
        case .expired:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = ((self.view.frame.width)/3*2)
            }
        }
    }
    
    func navigationTitleSetup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
    }
    
    func tabBarSetup() {
        self.tabBarController?.tabBar.layer.borderWidth = 0.50
        self.tabBarController?.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
}

extension FoodListViewController: UITableViewDelegate {
    
    // header高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
    
    // footer高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    // row高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.frame = tableView.frame
        view.backgroundColor = .white
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let key = foodsKeyArray[indexPath.section]
        
        guard let foods = foodsDic[key] else { return }
        
        let food = foods[indexPath.row]
        
        selectedFood = food
        
        if !tableView.isEditing {
            self.performSegue(withIdentifier: "SegueFoodDetail", sender: nil)
        }
    }
    
    // section content
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionView: SectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionView") as? SectionView
        else { return UIView() }
        
        sectionView.isExpand = self.isExpendDataList[section]
        sectionView.buttonTag = section
        sectionView.delegate = self
        
        let key: String = foodsKeyArray[section]
        //        let foods: [Foods]? = foodsDic[key]
        
        var picName = "groceries"
        if let imageName = sectionImage[key] {
            picName = imageName
        }
        
        sectionView.imageView.image = UIImage(named: picName)
        sectionView.titleLabel.text = foodsKeyArray[section]
        sectionView.amountLabel.text = "總計 \(String(foodsDic[foodsKeyArray[section]]?.count ?? 0)) 項"
        
        return sectionView
    }
    
}

extension FoodListViewController: UITableViewDataSource {
    
    // section 數量
    func numberOfSections(in tableView: UITableView) -> Int {
        return foodsKeyArray.count
    }
    
    // row 數量(第一個Section True(被點擊展開）-> 回傳此Section 類別數量的Cell 否則顯示0個(折疊）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isExpendDataList[section] {
            
            return foodsDic[foodsKeyArray[section]]?.count ?? 0
       
        } else {
            
            return 0
            
        }
    }
    
    // row content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell: CellView = tableView.dequeueReusableCell(withIdentifier: "CellView", for: indexPath) as? CellView else { return UITableViewCell() }
        
        let food = foodsDic[foodsKeyArray[indexPath.section]]![indexPath.row]
        
        cell.setup(data: food)
        
        return cell
    }
    
}

extension FoodListViewController: SectionViewDelegate {
    
    func sectionView(_ sectionView: SectionView, _ didPressTag: Int, _ isExpand: Bool) {
        self.isExpendDataList[didPressTag] = !isExpand
        self.tableView.reloadSections(IndexSet(integer: didPressTag), with: .automatic)
    }
    
}

//掃描發票用在這
extension FoodListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        //        if let image = info[.originalImage] as? UIImage {
        //
        //        }
        
        takingPicture.dismiss(animated: true, completion: nil)
    }
}

//MenuButton
extension FoodListViewController {
    
    func expandingMenuButton() {
        let btnSize: CGSize = CGSize(width: 100.0, height: 100.0)
        let xAxis = self.view.bounds.width
        let yAxis = self.view.bounds.height
        let origin = CGPoint.zero
        let image = #imageLiteral(resourceName: "plus")
        let rotated = #imageLiteral(resourceName: "plus")
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: origin, size: btnSize), image: image, rotatedImage: rotated)
        
        menuButton.center = CGPoint(x: xAxis-50, y: yAxis-225)
        self.view.addSubview(menuButton)
        
        func showAlert(_ title: String) {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let imageItem1 = #imageLiteral(resourceName: "keyboard")
        let item1 = ExpandingMenuItem(size: btnSize, title: "手動輸入",
                                      image: imageItem1,
                                      highlightedImage: imageItem1,
                                      backgroundImage: imageItem1,
                                      backgroundHighlightedImage: imageItem1) {
            self.performSegue(withIdentifier: "SegueAddContent", sender: self)
        }
        
        let imageItem2 = #imageLiteral(resourceName: "camera")
        let item2 = ExpandingMenuItem(size: btnSize, title: "掃描發票",
                                      image: imageItem2,
                                      highlightedImage: imageItem2,
                                      backgroundImage: imageItem2,
                                      backgroundHighlightedImage: imageItem2) {
            
            self.takingPicture.sourceType = .camera
            
            self.takingPicture.allowsEditing = false
            
            self.takingPicture.delegate = self
            
            self.present(self.takingPicture, animated: true, completion: nil)
        }
        
        menuButton.addMenuItems([item1, item2])
        
    }
    
}
