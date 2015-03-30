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
    @IBAction func closeButtonDidPress(sender: AnyObject) {
        //signUpDialogView.hidden = true
        //view.hidden = true
        dismissViewControllerAnimated(true, completion: nil)
        signUpDialogView.animation = "fall"
        signUpDialogView.animateNext{
          self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // bug for it
        //performSegueWithIdentifier("backToHome", sender: self)

    }
    @IBAction func signUpButtonDidPress(sender: AnyObject)
    {
       
        if signUpMatricTextField.text != "" && signUpPassTextField.text != ""
        {
            var userer:PFUser = PFUser()
            userer.username = signUpMatricTextField.text
            userer.password = signUpPassTextField.text
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
    
    @IBAction func loginHereButton(sender: AnyObject) {
   
     performSegueWithIdentifier("loginBoxSegue", sender: self)
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
