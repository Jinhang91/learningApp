//
//  LoginViewController.swift
//  learningApp
//
//  Created by chinhang on 3/13/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit
protocol LoginViewControllerDelegate: class{
    func loginViewControllerDidLogin(controller:LoginViewController)
}

class LoginViewController: UIViewController
{
    
    weak var delegate: LoginViewControllerDelegate?
    
    @IBOutlet weak var titleLabel: DesignableLabel!
    @IBOutlet weak var matricTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    
    @IBOutlet weak var titleSecondLabel: DesignableLabel!
    
    @IBOutlet weak var loginDialogView: DesignableView!
    
    @IBAction func loginButtonDidPress(sender: AnyObject)
    {
        
        if matricTextField.text != "" && passwordTextField.text != ""
        {
            //view.showLoading()
            var matricEntr = matricTextField.text
            reachabbilityStatus == kReachableWithWifi
            
            PFUser.logInWithUsernameInBackground(matricTextField.text, password:passwordTextField.text) {
                (user: PFUser!, error: NSError!) -> Void in
                if user != nil
                {
                    println("\(matricEntr), you're successfully logged in")
                    self.titleLabel.text = "Welcome," + " " + self.matricTextField.text + " user"
                    self.titleLabel.textAlignment = NSTextAlignment.Center
                    self.titleLabel.textColor = UIColor.redColor()
                    self.loginDialogView.hidden = true
                    self.view.hidden = true
                   self.dismissViewControllerAnimated(true, completion: nil)
/*
                    let alert1 = UIAlertView()
                    alert1.title = "Search your group"
                    alert1.message = self.matricTextField.text + " user, enter your group name to join"
                    alert1.addButtonWithTitle("OK")
                    alert1.show()
                    
                    let alert = UIAlertView()
                    alert.title = "Successful"
                    alert.message = "Welcome, " + self.matricTextField.text + " user"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    
  */                  
                
                }
                    
                else if reachabbilityStatus == kNotReachableWithWifi {
                    let alert = UIAlertView()
                    alert.title = "No Internet!"
                    alert.message = "Network is not found"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    self.view.hideLoading()
                }
                    
                else
                {
                    println("\(matricEntr), please try again!")
                    self.loginDialogView.animation = "shake"
                    self.loginDialogView.force = 3
                    self.loginDialogView.animate()
                    self.view.hideLoading()
                    let alert = UIAlertView()
                    alert.title = "Try again."
                    alert.message = "Incorrect matric or password"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
        
        
        }
        
        else {
            self.titleLabel.transform = CGAffineTransformMakeTranslation(0, 0)
            self.titleLabel.text = "Please fill in all the fields"
            self.titleLabel.textAlignment = NSTextAlignment.Center
            self.titleLabel.textColor = UIColor.redColor()
            
            self.titleLabel.alpha = 1
            self.titleSecondLabel.alpha = 0
           
            
            loginDialogView.animation = "shake"
            loginDialogView.force = 3
            loginDialogView.animate()
            
            springWithDelay(1, 1, {
                self.titleSecondLabel.animation = "pop"
                self.titleSecondLabel.animate()
                self.titleSecondLabel.alpha = 1
                self.titleSecondLabel.hidden = false
                
                self.titleLabel.alpha = 0
            })
        }
       delegate?.loginViewControllerDidLogin(self)
    
    }
    
    @IBAction func closeButtonDidPress(sender: AnyObject) {
    
    
        loginDialogView.animation = "fall"
        loginDialogView.animate()

        dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func createAccountButton(sender: AnyObject) {
     performSegueWithIdentifier("signUpSegue", sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityStatusChanged", name: "ReachStatusChanged", object: nil)
    
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true)
    }

    func reachabilityStatusChanged(){
        if reachabbilityStatus == kReachableWithWifi{
            
        }
    }
}
