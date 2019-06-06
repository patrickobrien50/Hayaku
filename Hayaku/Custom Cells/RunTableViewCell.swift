//
//  RunTableViewCell.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/21/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit

class RunTableViewCell: UITableViewCell {

    @IBOutlet weak var runPositionLabel: UILabel!
    @IBOutlet weak var trophyImageView: UIImageView!
    @IBOutlet weak var runnerNameLabel: UILabel!
    @IBOutlet weak var runTimeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
