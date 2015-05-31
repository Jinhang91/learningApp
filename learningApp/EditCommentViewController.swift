//
//  EditCommentViewController.swift
//  learningApp
//
//  Created by chinhang on 5/15/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit
protocol EditCommentViewControllerDelegate: class{
    func doneButtonCommentDidTouch(controller:EditCommentViewController)
}

class EditCommentViewController: UIViewController {

    var objectTo: PFObject!
    weak var delegate:EditCommentViewControllerDelegate?
    
    @IBAction func closeButtonDidTouch(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func doneButtonDidTouch(sender: AnyObject) {
    
    self.objectTo["userer"] = PFUser.currentUser()
    self.objectTo["commentContent"] = self.commentTextView.text
    self.objectTo["edited"] = true
        
        self.objectTo.saveEventually{(success,error) -> Void in
            
            if error == nil{
                
                println("saved successfully")
                
            }
                
            else {
                println(error!.userInfo)
            }
        }
        delegate?.doneButtonCommentDidTouch(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var commentTextView: UITextView!
    
    override func viewDidAppear(animated: Bool) {
       // navigationController?.hidesBarsOnSwipe = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if navigationController?.navigationBarHidden == true {
            return true
        }
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // commentTextView.becomeFirstResponder()
        // navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        if self.objectTo != nil{
            
            self.commentTextView.text = self.objectTo["commentContent"] as? String
            
        }
            
        else{
            self.objectTo = PFObject(className: "Comment")
        }
    }
    

 
}
