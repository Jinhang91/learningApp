//
//  FavouriteTableViewCell.swift
//  learningApp
//
//  Created by chinhang on 5/8/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

protocol FavouriteTableViewCellDelegate: class{
    func favoriteMemberDidTouch(cell: FavouriteTableViewCell, sender:AnyObject)
}
class FavouriteTableViewCell: UITableViewCell {

    weak var delegate:FavouriteTableViewCellDelegate?
    
    @IBOutlet weak var groupAvatar: DesignableImageView!
    
    @IBOutlet weak var groupLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var topicLabel: DesignableButton!

    @IBOutlet weak var timeSign: UIImageView!
    
    @IBOutlet weak var authorSign: UIImageView!
    
    @IBOutlet weak var memberLabel: DesignableButton!
 
    
    @IBAction func topicDidTouch(sender: AnyObject) {
    topicLabel.animation = "pop"
    topicLabel.force = 3.0
    topicLabel.animate()
    }
    
    
    @IBAction func memberDidTouch(sender: AnyObject) {
    memberLabel.animation = "pop"
    memberLabel.force = 3.0
    memberLabel.animate()
    
        delegate?.favoriteMemberDidTouch(self, sender: sender)

    }
    
    
    
}
