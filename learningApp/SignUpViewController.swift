//
//  SignUpViewController.swift
//  learningApp
//
//  Created by chinhang on 3/13/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var textLabel: DesignableLabel!
    @IBOutlet weak var signUpMatricTextField: DesignableTextField!
    @IBOutlet weak var signUpPassTextField: DesignableTextField!
    
    @IBOutlet weak var textSecondLabel: DesignableLabel!
    
    @IBOutlet weak var signUpDialogView: DesignableView!
    
    @IBOutlet weak var lecturerButton: DesignableButton!
    
    @IBOutlet weak var studentButton: DesignableButton!
    
    var identity = false
    
    @IBAction func closeButtonDidPress(sender: AnyObject) {
      
        //dismissViewControllerAnimated(true, completion: nil)
        signUpDialogView.animation = "fall"
        signUpDialogView.animateNext{
          self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // bug for it
        //performSegueWithIdentifier("backToHome", sender: self)

    }
    
    @IBAction func lecturerButtonDidTouch(sender: AnyObject) {
        
        identity = true
        lecturerButton.selected = true
        studentButton.selected = false
        lecturerButton.setTitle("Lecturer", forState: UIControlState.Selected)
        lecturerButton.setTitleColor(UIColorFromRGB(0xFFFFFF), forState: UIControlState.Selected)
        lecturerButton.backgroundColor = UIColorFromRGB(0x56D7CD)
        lecturerButton.borderColor = UIColor.clearColor()
        
        lecturerButton.animation = "pop"
        lecturerButton.force = 1
        lecturerButton.animate()
        
        studentButton.setTitle("Student", forState: UIControlState.Normal)
        studentButton.setTitleColor(UIColorFromRGB(0x8495A7), forState: UIControlState.Normal)
        studentButton.backgroundColor = UIColorFromRGB(0xEFF1F4)
        studentButton.borderColor = UIColorFromRGB(0x8495A7)

        
      
    }
    
    @IBAction func studentButtonDidTouch(sender: AnyObject) {
        
        identity = false
        studentButton.selected = true
        lecturerButton.selected = false
        studentButton.setTitle("Student", forState: UIControlState.Selected)
        studentButton.setTitleColor(UIColorFromRGB(0xFFFFFF), forState: UIControlState.Selected)
        studentButton.backgroundColor = UIColorFromRGB(0x56D7CD)
        studentButton.borderColor = UIColor.clearColor()
        
        studentButton.animation = "pop"
        studentButton.force = 1
        studentButton.animate()
        
        lecturerButton.setTitle("Lecturer", forState: UIControlState.Normal)
        lecturerButton.setTitleColor(UIColorFromRGB(0x8495A7), forState: UIControlState.Normal)
        lecturerButton.backgroundColor = UIColorFromRGB(0xEFF1F4)
        lecturerButton.borderColor = UIColorFromRGB(0x8495A7)
    
    }
    

    
    @IBAction func signUpButtonDidPress(sender: AnyObject)
    {
       
        if signUpMatricTextField.text != "" && signUpPassTextField.text != "" && (lecturerButton.selected == true || studentButton.selected == true)
        {
            var userer:PFUser = PFUser()
            userer.username = signUpMatricTextField.text
            userer.password = signUpPassTextField.text
            
            if identity == true {
            userer["identity"] = true
            }
            else{
                userer["identity"] = false
            }
            
            view.showLoading()
            userer.signUpInBackgroundWithBlock{
                (success:Bool!, error:NSError!)->Void in
                if !(error != nil){
                    println("Sign Up Successful")
                    
                    let alert = UIAlertView()
                    alert.title = "Sign Up Successful"
                    alert.message = "Please log in with your new created " + self.signUpMatricTextField.text + " account"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                 
                    self.view.hideLoading()
                    PFUser.logOut()
                    self.dismissViewControllerAnimated(true, completion: nil)

                }else{
                    let errorString = error.userInfo!["error"] as String
                    println(errorString)
                    self.textLabel.text = "Error, please try again."
                    self.textLabel.textAlignment = NSTextAlignment.Center
                    self.textLabel.textColor = UIColor.redColor()
                    self.view.hideLoading()
                }
            }

        }
        
        else
        {
            self.textLabel.text = "Please fill in all the fields"
            self.textLabel.textAlignment = NSTextAlignment.Center
            self.textLabel.textColor = UIColor.redColor()
            self.textLabel.alpha = 1
            self.textSecondLabel.alpha = 0
            tabBarController?.tabBar.hidden = false
            signUpDialogView.animation = "shake"
            signUpDialogView.animate()

            springWithDelay(1, 1, {
                self.textLabel.alpha = 0
                self.textSecondLabel.alpha = 1
                self.textSecondLabel.animation = "pop"
                self.textSecondLabel.animate()
                self.textSecondLabel.hidden = false
            })
            
            
        }
 
    
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
