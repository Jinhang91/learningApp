//
//  CommentsTableViewCell.swift
//  learningApp
//
//  Created by chinhang on 3/17/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

protocol CommentsTableViewCellDelegate: class {
    func commentsTableViewCellDidTouchUpvote(cell: CommentsTableViewCell, sender: AnyObject)
    func commentsTableViewCellDidTouchEvaluate(cell: CommentsTableViewCell, sender:AnyObject)
}

class CommentsTableViewCell: PFTableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var upvoteButton: SpringButton!

    @IBOutlet weak var evaluateButton: SpringButton!

    weak var delegate: CommentsTableViewCellDelegate?

    @IBAction func upvoteButtonDidTouch(sender: AnyObject) {
        upvoteButton.animation = "pop"
        upvoteButton.force = 3
        upvoteButton.animate()
        SoundPlayer.play("upvote.wav")

        delegate?.commentsTableViewCellDidTouchUpvote(self , sender: sender)
    }


    @IBAction func evaluateButtonDidTouch(sender: AnyObject) {
    
        evaluateButton.animation = "pop"
        evaluateButton.force = 3
        evaluateButton.animate()
        
        delegate?.commentsTableViewCellDidTouchEvaluate(self , sender: sender)
    }

    }



