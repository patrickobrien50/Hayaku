//
//  ResultsTableViewCell.swift
//  Hayaku
//
//  Created by Patrick O'Brien on 10/3/18.
//  Copyright © 2018 Patrick O'Brien. All rights reserved.
//

import UIKit

class GameResultTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var resultsImageView: UIImageView!
    @IBOutlet weak var resultsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
