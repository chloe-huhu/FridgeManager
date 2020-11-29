//
//  SectionView.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/28.
//

import UIKit

protocol SectionViewDelegate: class {
    func sectionView(_ sectionView: SectionView, _ didPressTag: Int, _ isExpand: Bool)
}

class SectionView: UITableViewHeaderFooterView {

    @IBOutlet weak var cardView: CardView!
    @IBOutlet var foodImage: UIImageView!
    @IBOutlet var foodTitleLabel: UILabel!
    @IBOutlet var foodAmountLabel: UILabel!
    @IBOutlet weak var foodExpireDate: UILabel!
    @IBOutlet var moreDataBtn: UIButton!
    
    weak var delegate: SectionViewDelegate?
    var buttonTag: Int!
    var isExpand: Bool!
    
    @IBAction func pressExpendBtn(_ sender: UIButton) {
        self.delegate?.sectionView(self, self.buttonTag, self.isExpand)
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
//    }
}
