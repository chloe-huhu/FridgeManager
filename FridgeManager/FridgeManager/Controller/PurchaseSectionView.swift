//
//  PurchaseSectionView.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/30.
//

import UIKit

//protocol PurchaseSectionViewDelegate: class {
//    func sectionView(_ sectionView: PurchaseSectionView, _ didPressTag: Int, _ isExpand: Bool)
//}

class PurchaseSectionView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var pendingLabel: UILabel!
    
//    @IBOutlet weak var moreButton: UIButton!
    
//    weak var delegate: PurchaseSectionViewDelegate?
//    var buttonTag: Int!
//    var isExpand: Bool! // cell 的狀態(展開/縮合)
    
//    @IBAction func pressExpendBtn(_ sender: UIButton) {
//        self.delegate?.sectionView(self, self.buttonTag, self.isExpand)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBackground()
    }
    
    private func setupBackground() {
        let background = UIView()
        background.backgroundColor = .white
        self.backgroundView = background
    }
}
