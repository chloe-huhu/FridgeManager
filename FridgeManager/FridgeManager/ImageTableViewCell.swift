//
//  ImageTableViewCell.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/23.
//

import UIKit
import Kingfisher

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup(data: Recipe) {
        
        let photo = URL(string: data.photo)
    
        recipeImageView.kf.setImage(with: photo, options: [.transition(.fade(0.5))])
    }
    
    
}
