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
    func loginCloseViewControllerDidTouch(controller:LoginViewController)
}

class LoginViewController: UIViewController
{
    
    weak var delegate: LoginViewControllerDelegate?
    
    @IBOutlet weak var titleLabel: DesignableLabel!
    @IBOutlet weak var matricTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    
    @IBOutlet weak var logoLabel: DesignableImageView!

    
    @IBOutlet weak var loginDialogView: DesignableView!
    
    @IBOutlet weak var loginButton: DesignableButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBAction func loginButtonDidPress(sender: AnyObject)
    {
    
        if matricTextField.text != "" && passwordTextField.text != ""
        {
            //view.showLoading()
            var matricEntr = matricTextField.text
            self.loginButton.setTitle("", forState: UIControlState.Normal)
            self.loadingIndicator.hidden = false
            reachabbilityStatus == kReachableWithWifi
            
            PFUser.logInWithUsernameInBackground(matricTextField.text, password:passwordTextField.text) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil
                {
                    println("\(matricEntr), you're successfully logged in")
       
                    self.dismissViewControllerAnimated(true, completion: nil)
                    let alert = UIAlertView()
                    alert.title = "Successful"
                    alert.message = "Welcome, " + self.matricTextField.text + " user"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                   
                    
                self.delegate?.loginViewControllerDidLogin(self)
                }
                    
                else if reachabbilityStatus == kNotReachableWithWifi {
                    let alert = UIAlertView()
                    alert.title = "No Internet!"
                    alert.message = "Network is not found"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    
                    self.loginButton.setTitle("LOGIN", forState: UIControlState.Normal)
                    self.loadingIndicator.hidden = true
                    
                    self.view.hideLoading()
                }
                    
                else
                {
                    println("\(matricEntr), please try again!")
                    self.loginDialogView.animation = "shake"
                    self.loginDialogView.force = 3
                    self.loginDialogView.animate()
                    
                    self.loginButton.setTitle("LOGIN", forState: UIControlState.Normal)
                    self.loadingIndicator.hidden = true
                    
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
            self.titleLabel.hidden = false
            self.titleLabel.alpha = 1
            self.logoLabel.alpha = 0
            
            self.loginButton.setTitle("LOGIN", forState: UIControlState.Normal)
            self.loadingIndicator.hidden = true
            
            loginDialogView.animation = "shake"
            loginDialogView.force = 3
            loginDialogView.animate()
            
            springWithDelay(1, 1, {

                self.logoLabel.alpha = 1

                
                self.titleLabel.alpha = 0
            })
        }

    }
    
    @IBAction func closeButtonDidPress(sender: AnyObject) {
    
    
        loginDialogView.animation = "fall"
        loginDialogView.animate()
        dismissViewControllerAnimated(true, completion: nil)

        delegate?.loginCloseViewControllerDidTouch(self)
    }
    
    @IBAction func createAccountButton(sender: AnyObject) {
     performSegueWithIdentifier("signUpSegue", sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        PFUser.logOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PFUser.logOut()
  NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityStatusChanged", name: "ReachStatusChanged", object: nil)
    
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }

    func reachabilityStatusChanged(){
        if reachabbilityStatus == kReachableWithWifi{
            
        }
    }
}
