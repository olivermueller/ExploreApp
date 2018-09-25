//
//  ModelDataTableViewCell.swift
//  UIQuiz
//
//  Created by Niels Andreas Østman on 25/09/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import UIKit

class ModelDataTableViewCell: UITableViewCell {
    @IBOutlet weak var signImage: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var ISOLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
