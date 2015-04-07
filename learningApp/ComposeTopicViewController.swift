//
//  ComposeTopicViewController.swift
//  learningApp
//
//  Created by chinhang on 3/8/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit



class ComposeTopicViewController: UIViewController {
    var groupCreated:PFObject?
    
    
    @IBOutlet weak var titleText: UITextView!

    @IBOutlet weak var contentText: UITextView!

    @IBOutlet weak var viewBack: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var submitTopicButton: UIBarButtonItem!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText.becomeFirstResponder()
       // navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)

         UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
          UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)
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
    
        view.showLoading()
        var topic: PFObject = PFObject(className: "Topics")
        
        if titleText.text != "" && contentText.text != "" {
        topic["title"] = titleText.text
        topic["content"] = contentText.text
        topic["userer"] = PFUser.currentUser()
        topic["parent"] = groupCreated
        topic.save()
        
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
   view.hideLoading()
  self.dismissViewControllerAnimated(true, completion: nil)
        
        
//self.navigationController?.popToRootViewControllerAnimated(true)
    }
    

}
