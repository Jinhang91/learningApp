//
//  EditTopicViewController.swift
//  learningApp
//
//  Created by chinhang on 5/14/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class EditTopicViewController: UIViewController {

    var titleText:String?
    var contentText:String?
    
    var objectTo:PFObject!
    var groupCreated: PFObject?
    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitTopicDidTouch(sender: AnyObject) {
        
        self.objectTo["userer"] = PFUser.currentUser()
        self.objectTo["title"] = self.titleTextView.text
        self.objectTo["content"] = self.contentTextView.text
   
        
        self.objectTo.saveEventually{(success,error) -> Void in
        
            if error == nil{
             
                println("saved successfully")
                
            }
        
            else {
                println(error.userInfo)
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextView.becomeFirstResponder()
       // navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        if self.objectTo != nil{
            self.titleTextView.text = self.objectTo["title"] as? String
            self.contentTextView.text = self.objectTo["content"] as? String
        }

        else{
            self.objectTo = PFObject(className: "Topics")
        }
    }
    
    
    @IBOutlet weak var titleTextView: DesignableTextView!

    @IBOutlet weak var contentTextView: DesignableTextView!


}
