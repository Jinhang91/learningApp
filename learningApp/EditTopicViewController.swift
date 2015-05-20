//
//  EditTopicViewController.swift
//  learningApp
//
//  Created by chinhang on 5/14/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit
protocol EditTopicViewControllerDelegate: class{
    func doneButtonDidTouch(controller:EditTopicViewController)
}

class EditTopicViewController: UIViewController {

    var objectTo:PFObject!
    var groupCreated: PFObject?
    weak var delegate:EditTopicViewControllerDelegate?
    
    @IBOutlet weak var startingField: DesignableTextField!
    @IBOutlet weak var endingField: DesignableTextField!
    
    @IBAction func startingDidTouch(sender: DesignableTextField) {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 200))
        
        
        var datePickerView  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 0, 0, 0))
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        inputView.addSubview(datePickerView) // add date picker to UIView
     
        sender.inputView = inputView
        datePickerView.addTarget(self, action: Selector("handleStartingDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    @IBAction func endingDidTouch(sender: DesignableTextField) {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 200))
        
        var datePickerView  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 0, 0, 0))
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        inputView.addSubview(datePickerView) // add date picker to UIView
        
        sender.inputView = inputView
        datePickerView.addTarget(self, action: Selector("handleEndingDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleStartingDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy, HH:mm"
        startingField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func handleEndingDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy, HH:mm"
        endingField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true)
    }
    

    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitTopicDidTouch(sender: AnyObject) {
        
        self.objectTo["userer"] = PFUser.currentUser()
        self.objectTo["title"] = self.titleTextView.text
        self.objectTo["content"] = self.contentTextView.text
        self.objectTo["startingDate"] = self.startingField.text
        self.objectTo["endingDate"] = self.endingField.text
        self.objectTo["edited"] = true
        
        self.objectTo.saveEventually{(success,error) -> Void in
        
            if error == nil{
             
                println("saved successfully")
                
            }
        
            else {
                println(error.userInfo)
            }
        }
        delegate?.doneButtonDidTouch(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.hidesBarsOnSwipe = true
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
        
        startingField.becomeFirstResponder()
       // navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        if self.objectTo != nil{
            self.titleTextView.text = self.objectTo["title"] as? String
            self.contentTextView.text = self.objectTo["content"] as? String
            self.startingField.text = self.objectTo["startingDate"] as? String
            self.endingField.text = self.objectTo["endingDate"] as? String
       //     self.objectTo.updatedAt = timeAgoSinceDate(objectTo.createdAt, true)
        }

        else{
            self.objectTo = PFObject(className: "Topics")
        }
    }
    
    
    @IBOutlet weak var titleTextView: DesignableTextField!

    @IBOutlet weak var contentTextView: DesignableTextView!


}
