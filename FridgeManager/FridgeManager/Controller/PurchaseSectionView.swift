//
//  PurchaseSectionView.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/30.
//

import UIKit


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
