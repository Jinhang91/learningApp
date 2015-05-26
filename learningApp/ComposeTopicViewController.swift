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
    
    

    @IBOutlet weak var titleText: UITextField!

    @IBOutlet weak var contentText: DesignableTextView!

    @IBOutlet weak var viewBack: UIView!
    
    @IBOutlet weak var submitTopicButton: UIBarButtonItem!

    @IBOutlet weak var startingTextField: DesignableTextField!
    @IBOutlet weak var endingTextField: DesignableTextField!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    weak var delegate: ComposeTopicViewControllerDelegate?
   
    override func viewDidLoad() {
        super.viewDidLoad()
    
        startingTextField.becomeFirstResponder()
      //  navigationController?.navigationBar.barStyle = UIBarStyle.
       // navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)

         UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
          UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        
      
    }
    
    override func viewDidAppear(animated: Bool) {
    //  navigationController?.hidesBarsOnSwipe = true
      //  navigationController?.navigationBar.topItem?.title = "New Post"
      //  navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
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
    

    @IBAction func startingDidTouch(sender: DesignableTextField) {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 200))
        
        
        var datePickerView  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 0, 0, 0))
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        datePickerView.contentMode = UIViewContentMode.Center
        inputView.addSubview(datePickerView) // add date picker to UIView
   /*
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (100/2), 0, 100, 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside) // set button click event
     */
        sender.inputView = inputView
        datePickerView.addTarget(self, action: Selector("handleStartingDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    @IBAction func endingDidTouch(sender: DesignableTextField) {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 200))
        
        
        var datePickerView  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 0, 0, 0))
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        datePickerView.contentMode = UIViewContentMode.Center
        inputView.addSubview(datePickerView) // add date picker to UIView
        
        sender.inputView = inputView
        datePickerView.addTarget(self, action: Selector("handleEndingDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleStartingDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy, HH:mm"
        startingTextField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func handleEndingDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy, HH:mm"
        endingTextField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func doneButton(sender: UIButton){
        startingTextField.resignFirstResponder()
        endingTextField.resignFirstResponder()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true)
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
        topic["edited"] = false
        topic["startingDate"] = startingTextField.text
        topic["endingDate"] = endingTextField.text
        
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
