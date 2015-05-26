//
//  ShowMemberViewController.swift
//  learningApp
//
//  Created by chinhang on 5/25/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit
protocol ShowMemberViewControllerDelegate: class{
    func showMemberCloseDidTouch(controller:ShowMemberViewController)
}

class ShowMemberViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate:ShowMemberViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    var groupFav:PFObject?
    
    
    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
        delegate?.showMemberCloseDidTouch(self)
    }
    
    var timelineMemberData:NSMutableArray! = NSMutableArray()
    
    func loadData(){
        timelineMemberData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findMemberData:PFQuery = PFUser.query()
        
        findMemberData.whereKey("favorited", equalTo: groupFav?.objectId)
        
        findMemberData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                for object in objects {
                    self.timelineMemberData.addObject(object)
                
                
                }
                let array:NSArray = self.timelineMemberData.reverseObjectEnumerator().allObjects
                self.timelineMemberData = array.mutableCopy() as NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
    

            }
                
            else{
                println("no data")
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.delegate = self
        tableView.dataSource = self
        println(groupFav)
    }
    
    var isFirstTime = true
    
    override func viewDidAppear(animated: Bool) {
        
        if isFirstTime {
            self.view.showLoading()
            self.tableView.setNeedsDisplay()
            self.tableView.layoutIfNeeded()
            self.loadData()
            self.tableView.reloadData()
            
            isFirstTime = false
        }
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(timelineMemberData.count)
        return timelineMemberData.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath) as ShowMemberTableViewCell
        
        cell.studentLabel.alpha = 0
    
        var findUsererData:PFQuery = PFUser.query()
        findUsererData.whereKey("favorited", equalTo: groupFav?.objectId)
        findUsererData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                
                
                let user:PFUser = (objects as NSArray).lastObject as PFUser
             //   println(user.objectId)
            
                cell.studentLabel.text = user.username
                
                spring(1.0){
                cell.studentLabel.alpha = 1
                }
                
                
            }
            else{
                println("No username detected")
            }
            
        })

        
        return cell
    }

}
