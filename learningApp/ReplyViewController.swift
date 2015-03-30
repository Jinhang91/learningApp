//
//  ReplyViewController.swift
//  learningApp
//
//  Created by chinhang on 3/18/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class ReplyViewController: UIViewController {
    
    var comment:PFObject?
    var topic:PFObject?
    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var sendReplyButton: UIBarButtonItem!
    @IBOutlet weak var replyTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Gill Sans", size: 19)!], forState: UIControlState.Normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Gill Sans", size: 19)!], forState: UIControlState.Normal)
        replyTextView.becomeFirstResponder()
        
          }

    @IBAction func cancelButtonDidTouch(sender: AnyObject) {
dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func replyButtonDidTouch(sender: AnyObject) {
        view.showLoading()
        var comment:PFObject = PFObject(className: "Comment")
        
        
        if replyTextView.text != ""  {
            comment["commentContent"] = replyTextView.text
            comment["userer"] = PFUser.currentUser()
            comment["parent"] = topic
            comment.save()
            
            var post = comment["parent"] as PFObject
       
            post.fetchIfNeededInBackgroundWithBlock {
                (post: PFObject!, error: NSError!) -> Void in
                let title = post["title"] as NSString
                println("\(title)")    // do something with your title variable
                self.view.hideLoading()
            }
           
            
        }
        else
        {
            let alert = UIAlertView()
            alert.title = "Failed to post!"
            alert.message = "Please fill in the field"
            alert.addButtonWithTitle("OK")
            alert.show()
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)


}
    

}