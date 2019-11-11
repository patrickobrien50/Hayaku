//
//  StreamsCollectionViewCell.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/10/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit

class StreamsCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

    }
    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var streamTitleLabel: UILabel!
    @IBOutlet weak var viewerCountLabel: UILabel!
    @IBOutlet weak var streamerLabel: UILabel!
}
