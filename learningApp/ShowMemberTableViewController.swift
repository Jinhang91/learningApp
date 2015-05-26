//
//  ShowMemberTableViewController.swift
//  learningApp
//
//  Created by chinhang on 5/26/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class ShowMemberTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    var timelineMemberData:NSMutableArray! = NSMutableArray()
    var isFirstTime = true
    var groupFav:PFObject?
    
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return timelineMemberData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath) as ShowMemberTableViewCell

        cell.studentLabel.alpha = 0
        var findUsererData:PFQuery = PFUser.query()
        findUsererData.whereKey("favorited", equalTo: groupFav?.objectId)

        findUsererData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                
                
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                   println(user.objectId)
                
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

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
