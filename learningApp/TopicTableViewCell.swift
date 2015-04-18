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

class TopicTableViewCell: PFTableViewCell,UITextViewDelegate {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var upvoteButton: SpringButton!
    @IBOutlet weak var commentButton: SpringButton!
    
    @IBOutlet weak var contentTextView: AutoTextView!
    
    @IBOutlet weak var authorSign: UIImageView!
    @IBOutlet weak var timeSign: UIImageView!
    
    var likeCount = 0
    
    weak var delegate: TopicTableViewCellDelegate?
    
    @IBAction func upvoteButtonDidTouch(sender: AnyObject) {
        upvoteButton.animation = "pop"
        upvoteButton.force = 3
        upvoteButton.animate()
        SoundPlayer.play("upvote.wav")
       

        delegate?.topicTableViewCellDidTouchUpvote(self , sender: sender)
    }
    
    
    @IBAction func commentButtonDidTouch(sender: AnyObject) {
        commentButton.animation = "pop"
        commentButton.force = 3
        commentButton.animate()
    
        delegate?.topicTableViewCellDidTouchComment(self, sender: sender)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func textView(textView: AutoTextView!, shouldInteractWithURL URL: NSURL!, inRange characterRange: NSRange) -> Bool {
        println("Link Selected!")
        
        let webViewController = WebViewController()
      
        return false
    }
    
    
}
