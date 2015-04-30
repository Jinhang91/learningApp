//
//  EvaluationTableViewCell.swift
//  learningApp
//
//  Created by chinhang on 4/30/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class EvaluationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var studentMatric: UILabel!
    @IBOutlet weak var ratingDisplayed: SpringButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func ratingDidTouch(sender: AnyObject) {
        ratingDisplayed.animation = "pop"
        ratingDisplayed.force = 3
        ratingDisplayed.animate()
    }

}
