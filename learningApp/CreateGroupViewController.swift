//
//  CreateGroupViewController.swift
//  learningApp
//
//  Created by chinhang on 3/22/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

protocol CreateGroupViewControllerDelegate : class{
    func createGroupViewControllerDidTouch(controller:CreateGroupViewController)
}

class CreateGroupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageData: NSData?
    var imageDefaultData: NSData?
    weak var delegate: CreateGroupViewControllerDelegate?
    
    @IBOutlet weak var groupDialogView: DesignableView!
    @IBOutlet weak var avatarGroup: DesignableImageView!
    @IBOutlet weak var groupNameLabel: DesignableLabel!
    @IBOutlet weak var groupNameTextField: DesignableTextField!
    
    @IBOutlet weak var groupNameLabel2: DesignableLabel!
    
    @IBOutlet weak var avatarLabel: DesignableLabel!
    
    @IBOutlet weak var pickPhotoButton: DesignableButton!
    @IBOutlet weak var createGroupButton: DesignableButton!
    
    //@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBAction func closeButtonDidTouch(sender: AnyObject) {
    
        groupDialogView.animation = "fall"
        avatarGroup.animation = "fall"
        avatarGroup.animate()
        groupDialogView.animateNext{
        self.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

        }
    }
    
    @IBAction func pickPhotoButtonDidTouch(sender: AnyObject) {
        
          var imagePicker:UIImagePickerController = UIImagePickerController()
         imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
         imagePicker.delegate = self
        
         groupNameLabel2.hidden = true
         self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
 func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary!) {
        
        let pickedImage:UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
    
        let scaledImage = self.scaleImageWith(pickedImage, and: CGSizeMake(70, 70))
               //Scale down image
        
        imageData = UIImagePNGRepresentation(scaledImage)
        avatarGroup.image = scaledImage
        groupNameLabel2.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func imageDefault(){
        let pickedDefaultImage:UIImage = UIImage(named: "avatarDefault")!
        imageDefaultData = UIImagePNGRepresentation(pickedDefaultImage)

    }
  
   
    func scaleImageWith(image:UIImage, and newSize:CGSize) ->UIImage{
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    @IBAction func createGroupButtonDidTouch(sender: AnyObject) {
        
        
            if groupNameTextField.text != "" && avatarGroup.image != nil {
            if let data = imageData  {
            let imageFile:PFFile = PFFile(data: imageData)

            var groupCreated:PFObject = PFObject(className: "Groups")
            groupCreated.setObject(imageFile, forKey: "groupAvatar")
            groupCreated["name"] = groupNameTextField.text
            groupCreated["userer"] = PFUser.currentUser()
            
            groupCreated.save()
            
            println("Successful to create!")
            let alert = UIAlertView()
            alert.title = "Successful!"
            alert.message = "Your " + self.groupNameTextField.text + " group is created"
            alert.addButtonWithTitle("OK")
            alert.show()
            
           
            self.dismissViewControllerAnimated(true, completion: nil)
            
            }
      }
            if groupNameTextField.text != "" && avatarGroup.image != nil {
                self.imageDefault()
                if let data = imageDefaultData  {
                let imageFile:PFFile = PFFile(data: imageDefaultData)
                
                var groupCreated:PFObject = PFObject(className: "Groups")
                groupCreated.setObject(imageFile, forKey: "groupAvatar")
                groupCreated["name"] = groupNameTextField.text
                groupCreated["userer"] = PFUser.currentUser()
                
                groupCreated.save()
                
                println("Successful to create!")
                let alert = UIAlertView()
                alert.title = "Successful!"
                alert.message = "Your " + self.groupNameTextField.text + " group is created"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                
                self.dismissViewControllerAnimated(true, completion: nil)
                    
            }
        }
    
        if groupNameTextField.text == "" {
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
        delegate?.createGroupViewControllerDidTouch(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

   
}
