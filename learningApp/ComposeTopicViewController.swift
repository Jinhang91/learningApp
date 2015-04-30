//
//  ComposeTopicViewController.swift
//  learningApp
//
//  Created by chinhang on 3/8/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

protocol ComposeTopicViewControllerDelegate: class{
    func submitTopicDidTouch(controller:ComposeTopicViewController)
}

class ComposeTopicViewController: UIViewController {
    var groupCreated:PFObject?
    
    
    @IBOutlet weak var titleText: UITextView!

    @IBOutlet weak var contentText: UITextView!

    @IBOutlet weak var viewBack: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var submitTopicButton: UIBarButtonItem!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    weak var delegate: ComposeTopicViewControllerDelegate?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText.becomeFirstResponder()
       // navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)

         UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
          UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        
        if titleText.text == nil {
            submitTopicButton.enabled = false
        }
        else{
            submitTopicButton.enabled = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
       
      //  navigationController?.navigationBar.topItem?.title = "New Post"
      //  navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    @IBAction func cancelButtonDidTouch(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func submitTopic(sender: AnyObject) {
    
        var topic: PFObject = PFObject(className: "Topics")
        
        if titleText.text != "" && contentText.text != "" {
        topic["title"] = titleText.text
        topic["content"] = contentText.text
        topic["userer"] = PFUser.currentUser()
        topic["parent"] = groupCreated
        topic["whoLiked"] = []
        
            
        
            topic.saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                if success == true {
                    println("\(self.titleText.text) topic created")
                } else {
                    println(error)
                }
                
            }

        
            var mama = topic["parent"] as PFObject
            
            mama.fetchIfNeededInBackgroundWithBlock {
                (mama: PFObject!, error: NSError!) -> Void in
                if error == nil{
                    let title = mama["name"] as NSString
                    println("\(title)")
                }
                else{
                    println("No group is identifed")
                }
            }

        }

        else
        {
            let alert = UIAlertView()
            alert.title = "Failed to post!"
            alert.message = "Please fill in all the fields"
            alert.addButtonWithTitle("OK")
            alert.show()

        }
   
  self.dismissViewControllerAnimated(true, completion: nil)
  delegate?.submitTopicDidTouch(self)
        
//self.navigationController?.popToRootViewControllerAnimated(true)
    }
    

}
