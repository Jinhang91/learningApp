//
//  GroupTableViewCell.swift
//  learningApp
//
//  Created by chinhang on 3/14/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarGroup: DesignableImageView!

    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
