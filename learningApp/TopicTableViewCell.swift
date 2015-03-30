//
//  TopicTableViewCell.swift
//  learningApp
//
//  Created by chinhang on 3/8/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit
protocol TopicTableViewCellDelegate: class {
    func topicTableViewCellDidTouchUpvote(cell: TopicTableViewCell, sender: AnyObject)
    func topicTableViewCellDidTouchComment(cell: TopicTableViewCell, sender: AnyObject)
}

class TopicTableViewCell: PFTableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var upvoteButton: SpringButton!
    @IBOutlet weak var commentButton: SpringButton!
    
 //   @IBOutlet weak var content2Label: AutoTextView!
    
    weak var delegate: TopicTableViewCellDelegate?
    
    @IBAction func upvoteButtonDidTouch(sender: AnyObject) {
        upvoteButton.animation = "pop"
        upvoteButton.force = 3
        upvoteButton.animate()
        
        delegate?.topicTableViewCellDidTouchUpvote(self , sender: sender)
    }
    
    
    @IBAction func commentButtonDidTouch(sender: AnyObject) {
        commentButton.animation = "pop"
        commentButton.force = 3
        commentButton.animate()
    
        delegate?.topicTableViewCellDidTouchComment(self, sender: sender)
    }
/*
    func configureTopic(PFObject){
     
        titleLabel.text = topic.objectForKey("title") as? String
        contentLabel.text = topic.objectForKey("content") as? String
    }
  */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
