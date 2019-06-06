//
//  SeriesTableViewCell.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/1/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit

class SeriesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var seriesTableViewCellLabel: UILabel!
    @IBOutlet weak var seriesTableViewCellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
