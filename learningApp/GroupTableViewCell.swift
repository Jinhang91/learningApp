//
//  GroupTableViewCell.swift
//  learningApp
//
//  Created by chinhang on 3/14/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

protocol GroupTableViewCellDelegate: class{
    func groupTableViewCellFavoriteDidTouch(cell:GroupTableViewCell, sender: AnyObject)
}

class GroupTableViewCell: UITableViewCell {

    weak var delegate: GroupTableViewCellDelegate?
    
    @IBOutlet weak var avatarGroup: DesignableImageView!

    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var topicNumber: DesignableButton!
    
    @IBOutlet weak var timeLabelSign: UIImageView!
    
    @IBOutlet weak var authorSign: UIImageView!
    

    @IBOutlet weak var favoriteButton: DesignableButton!
    
    @IBAction func favoriteButtonDidTouch(sender: AnyObject) {
   
     favoriteButton.animation = "pop"
     favoriteButton.force = 3
     favoriteButton.animate()
        
    delegate?.groupTableViewCellFavoriteDidTouch(self, sender: sender)
    }
    
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
