//
//  CreateViewController.swift
//  learningApp
//
//  Created by chinhang on 5/16/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

protocol CreateViewControllerDelegate : class{
    func createGroupViewControllerDidTouch(controller: CreateViewController)
    func closeGroupViewControllerDidTouch(controller: CreateViewController)
}

class CreateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imageData: NSData?
    var imageDefaultData: NSData?
    var scaledImage:UIImage?
    
    weak var delegate: CreateViewControllerDelegate?
    
    @IBOutlet weak var groupDialogView: DesignableView!
    
    @IBOutlet weak var avatarGroup: DesignableImageView!
    
    @IBOutlet weak var groupNameTextField: DesignableTextField!
    
    @IBOutlet weak var groupNameLabel: DesignableLabel!
    
    @IBOutlet weak var groupNameLabel2: DesignableLabel!
    
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    
    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        groupDialogView.animation = "fall"
        avatarGroup.animation = "fall"
        avatarGroup.animate()
        groupDialogView.animateNext{
            self.dismissViewControllerAnimated(true, completion: nil)
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
            
        }
        delegate?.closeGroupViewControllerDidTouch(self)
    }

    
    @IBAction func pickPhotoDidTouch(sender: AnyObject) {
        
        var imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        
        groupNameLabel2.hidden = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let pickedImage: UIImage = (info as NSDictionary).objectForKey(UIImagePickerControllerOriginalImage) as! UIImage
        scaledImage = self.scaleImageWith(pickedImage, and: CGSizeMake(70, 70))
        //Scale down image
        
        imageData = UIImagePNGRepresentation(scaledImage)
        avatarGroup.image = scaledImage
        groupNameLabel2.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    func scaleImageWith(image:UIImage, and newSize:CGSize) ->UIImage{
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func imageDefault(){
        let pickedDefaultImage:UIImage = UIImage(named: "avatarDefault")!
        imageDefaultData = UIImagePNGRepresentation(pickedDefaultImage)
        
    }
    
    @IBAction func createGroupDidTouch(sender: AnyObject) {
        if groupNameTextField.text != "" && avatarGroup.image == scaledImage {
            if let data = imageData  {
                let imageFile:PFFile = PFFile(data: imageData!)
                
                var groupCreated:PFObject = PFObject(className: "Groups")
                groupCreated.setObject(imageFile, forKey: "groupAvatar")
                groupCreated["name"] = groupNameTextField.text
                groupCreated["userer"] = PFUser.currentUser()
                groupCreated["whoFavorited"] = [PFUser.currentUser()!.objectId!]
                
                
                groupCreated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                    if success == true {
                        println("\(self.groupNameTextField.text) group created")
                    } else {
                        println(error)
                    }
                    
                }
                
                /*
                PFUser.currentUser().addUniqueObject(groupCreated.objectId, forKey: "favorited")
                PFUser.currentUser().saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                    if success == true {
                        println("joined")
                    } else {
                        println(error)
                    }
                    
                }
                */
                println("Successful to create!")
                let alert = UIAlertView()
                alert.title = "Successful!"
                alert.message = "Your " + self.groupNameTextField.text + " group is created"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                
            }
            delegate?.createGroupViewControllerDidTouch(self)
        }
            
        else if (groupNameTextField.text != "" && avatarGroup.image != nil) {
            self.imageDefault()
            if let data = imageDefaultData  {
                let imageFile:PFFile = PFFile(data: imageDefaultData!)
                
                var groupCreated:PFObject = PFObject(className: "Groups")
                groupCreated.setObject(imageFile, forKey: "groupAvatar")
                groupCreated["name"] = groupNameTextField.text
                groupCreated["userer"] = PFUser.currentUser()
                groupCreated["whoFavorited"] = [PFUser.currentUser()!.objectId!]
                
                groupCreated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                    if success == true {
                        println("\(self.groupNameTextField.text) group created")
                    } else {
                        println(error)
                    }
                    
                }
                /*
                PFUser.currentUser().addUniqueObject(groupCreated.objectId, forKey: "favorited")
                PFUser.currentUser().saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                    if success == true {
                        println("joined")
                    } else {
                        println(error)
                    }
                    
                }
                */
                println("Successful to create!")
                let alert = UIAlertView()
                alert.title = "Successful!"
                alert.message = "Your " + self.groupNameTextField.text + " group is created"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                
                self.dismissViewControllerAnimated(true, completion: nil)
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
                
            }
            delegate?.createGroupViewControllerDidTouch(self)
        }
            
        else if groupNameTextField.text == "" {
            println("Unsuccessful to create!")
            self.groupNameLabel.transform = CGAffineTransformMakeTranslation(0, 0)
            self.groupNameLabel.text = "Group name is necessary!"
            self.groupNameLabel.textAlignment = NSTextAlignment.Left
            self.groupNameLabel.textColor = UIColor.redColor()
            
            self.groupNameLabel.alpha = 1
            self.groupNameLabel2.alpha = 0
            self.groupNameLabel2.hidden = true
            
            groupDialogView.animation = "shake"
            groupDialogView.force = 1
            groupDialogView.animate()
            view.hideLoading()
            
            springWithDelay(1, 1, {
                self.groupNameLabel2.animation = "pop"
                self.groupNameLabel2.animate()
                self.groupNameLabel2.alpha = 1
                self.groupNameLabel2.hidden = false
                
                self.groupNameLabel.alpha = 0
            })
            
            
        }
        else{
            println("Very Unsuccessful to create!")
        }
        
    }

    
   
}
