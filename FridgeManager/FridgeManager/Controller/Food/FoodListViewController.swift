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
import Lottie

enum GoInfo {
    
    case newUser
    
    case user
}

class FoodListViewController: UIViewController {
    
    var goInfo: GoInfo = .user
    
    var fridgeID: String {
        
        guard let fridgeID = UserDefaults.standard.string(forKey: "FridgeID") else {
            
            return ""
        }
        
        return fridgeID
    }
    
    var ref: CollectionReference {
        
        return Firestore.firestore().collection("fridges").document(fridgeID).collection("foods")
    }
    
    var sectionImage: [String: String] = ["肉類": "turkey", "豆類": "beans", "雞蛋類": "eggs", "青菜類": "cabbage", "醃製類": "bacon", "水果類": "blueberries", "魚類": "fish", "海鮮類": "shrimp", "五穀根筋類": "grain", "飲料類": "coffee-3", "調味料類": "flour-1", "其他": "groceries"]
    
    var oriFoods: [Food] = [] {
        didSet {
            if oriFoods.isEmpty {
                emptyLabel.isHidden = false
                animationView.isHidden = false
                animationView.contentMode = .scaleAspectFit
                animationView.loopMode = .autoReverse
                animationView.animationSpeed = 0.5
                animationView.play()
            } else {
                animationView.isHidden = true
                emptyLabel.isHidden = true
            }
        }
    }
    
    var foodsDic: [String: [Food]] = [:]
    
    var foodsKeyArray: [String] = []
    
    var isExpendDataList: [Bool] = []
    
    var selectedFood: Food?
    
    var showCategory: ShowCategory = .all
    
    var showType: ShowType = .edit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup()
        tabBarSetup()
        dbListen()
        fetchData()
        
        switch goInfo {
        
        case .newUser: self.tabBarController?.selectedIndex = 3
            
        default: break
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        showCategory = .all
        btnPressedAnimation(type: .all)
        dbGet()
    }
    
    func fetchData() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 去Firebase找符合的uid
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: uid).getDocuments { (querySnapShot, error) in
            if let error = error {
                print("Error getting documnets : \(error)")
            } else {
                
                for document in querySnapShot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    do {
                        
                        let data = try document.data(as: User.self)
                        
                        UserDefaults.standard.setValue(data?.myFridges[0], forKey: "FridgeID")
                        
                        UserDefaults.standard.setValue(uid, forKey: "userUid")
                        
                        //                             var rootVC: UIViewController
                        //                              rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodListViewController")
                        
                    } catch {
                        print("error to decode", error)
                    }
                    return
                }
                
                
            }
        }
    }
    
    
    @IBOutlet weak var addNewFoodBtn: UIButton!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) { selectedData() }
    
    func selectedData() {
        switch showType {
        case .edit:
            editButton.image = #imageLiteral(resourceName: "trash")
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
    
    
    @IBOutlet weak var sliderView: UIView!
    
    @IBOutlet weak var animationView: AnimationView!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
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
                    
                    // print("現有的資料 \(document.documentID) => \(document.data())")
                    
                    do {
                        // 獲得某食材的資料
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
            // 產生key(Section)
            if foodsDic[food.category] == nil {
                // print("---- category is not in dictionary")
                self.foodsDic[food.category] = []
                self.isExpendDataList.append(false)
            }
            
            // 在key底下,新增value (Section:data1\data2)
            self.foodsDic[food.category]?.append(food)
        }
        
        self.foodsKeyArray = Array(self.foodsDic.keys.sorted())
        
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 有兩個perform segue，共用一個prepare，去分辨點選哪一個
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
    
    func btnPressedAnimation(type: ShowCategory) {
        
        switch showCategory {
        case .all:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
                self.sliderView.frame.origin.x = 0
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
    
    func navigationBarSetup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
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
