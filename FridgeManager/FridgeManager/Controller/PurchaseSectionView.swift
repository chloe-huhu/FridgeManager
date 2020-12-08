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
