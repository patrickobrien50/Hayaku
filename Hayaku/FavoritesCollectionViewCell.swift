//
//  FavoritesCollectionViewCell.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/7/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit




class FavoritesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var favoriteGameCellImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        closeButton.alpha = 0
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        
    }
    
}
