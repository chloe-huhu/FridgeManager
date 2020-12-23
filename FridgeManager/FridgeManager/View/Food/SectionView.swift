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
   
    var buttonTag: Int!
    
    var isExpand: Bool!
    
    weak var delegate: SectionViewDelegate?
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var moreDataBtn: UIButton!

    @IBAction func pressExpendBtn(_ sender: UIButton) {
        self.delegate?.sectionView(self, self.buttonTag, self.isExpand)
    }
    

}
