//
//  ReplyViewController.swift
//  learningApp
//
//  Created by chinhang on 3/18/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

protocol ReplyViewControllerDelegate: class{
    func sendReplyDidTouch(controller:ReplyViewController)
}

class ReplyViewController: UIViewController {
    
    var comment:PFObject?
    var topic:PFObject?
    
    weak var delegate: ReplyViewControllerDelegate?
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var sendReplyButton: UIBarButtonItem!
    @IBOutlet weak var replyTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]

        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)
        
       // navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)
        replyTextView.becomeFirstResponder()
        
          }

    override func viewDidAppear(animated: Bool) {
        
      //  navigationController?.navigationBar.topItem?.title = "Reply"
      //  navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    @IBAction func cancelButtonDidTouch(sender: AnyObject) {
dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func replyButtonDidTouch(sender: AnyObject) {
        
        var comment:PFObject = PFObject(className: "Comment")
        
        
        if replyTextView.text != ""  {
            comment["commentContent"] = replyTextView.text
            comment["userer"] = PFUser.currentUser()
            comment["parent"] = topic
            comment["whoLiked"] = []
            comment.save()
            
            var post = comment["parent"] as PFObject
       
            post.fetchIfNeededInBackgroundWithBlock {
                (post: PFObject!, error: NSError!) -> Void in
                let title = post["title"] as NSString
                println("\(title)")    // do something with your title variable
                
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
        delegate?.sendReplyDidTouch(self)

}
    

}