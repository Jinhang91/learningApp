//
//  FavouriteTableViewController.swift
//  learningApp
//
//  Created by chinhang on 5/8/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class FavouriteTableViewController: UITableViewController, LoginViewControllerDelegate, CreateGroupViewControllerDelegate {

    @IBOutlet weak var signOut: UIBarButtonItem!
    
    @IBAction func signOutButtonDidTouch(sender: AnyObject) {
        if PFUser.currentUser() != nil {
            
            let signOutDialog = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .Alert)
            
            let cancelIt = UIAlertAction(title: "Cancel", style: .Cancel)
                {
                    action -> Void in
            }
            
            let logOut = UIAlertAction(title: "Log out", style: .Default)
                {
                    action -> Void in
                    PFUser.logOut()
                    self.loadData()
                    let alert = UIAlertView()
                    alert.title = ""
                    alert.message = "Sign out successfully"
                    alert.addButtonWithTitle("OK")
                    alert.show()
            }
            
            signOutDialog.addAction(cancelIt)
            signOutDialog.addAction(logOut)
            self.presentViewController(signOutDialog, animated: true, completion: nil)
            
            
        }
            
        else {
            performSegueWithIdentifier("loginFavSegue", sender: self)
        }
    }

    
    @IBAction func createGroupDidTouch(sender: AnyObject) {
        if PFUser.currentUser() == nil{
            performSegueWithIdentifier("loginFavSegue", sender: self)
            let alert = UIAlertView()
            alert.title = "No user is detected"
            alert.message = "Log in with your account to make comments"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        else{
            performSegueWithIdentifier("createGroupFavSegue", sender: self)
        }
    }
    


    var timelineFavData:NSMutableArray = NSMutableArray()
    
    func loadData(){
        if PFUser.currentUser() == nil{
            signOut.title = "Log in"
        }
        else{
            signOut.title = PFUser.currentUser().username
        }
        timelineFavData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findGroupData:PFQuery = PFQuery(className: "Groups")
        findGroupData.whereKey("favorite", equalTo: true)
        findGroupData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                for object in objects {
                    self.timelineFavData.addObject(object)
                }
                
                let array:NSArray = self.timelineFavData.reverseObjectEnumerator().allObjects
                self.timelineFavData = array.mutableCopy() as NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            }
        })
    }
    
    var isFirstTime = true
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() == nil{
            signOut.title = "Log in"
        }
        else{
            signOut.title = PFUser.currentUser().username
        }
        
        if isFirstTime {
            self.view.showLoading()
            self.tableView.setNeedsDisplay()
            self.tableView.layoutIfNeeded()
            self.loadData()
            isFirstTime = false
        }
        
        //navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.topItem?.title = "Favorites"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let cancelButtonAttributes:NSDictionary = [NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 17)!, NSForegroundColorAttributeName:UIColorFromRGB(0x37B8B0)]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes, forState: UIControlState.Normal)
        
        var refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColorFromRGB(0x4FD7CE)
        refreshControl.tintColor = UIColor.whiteColor()
        
        var refreshTitle:NSMutableAttributedString = NSMutableAttributedString(string: "Refreshing Groups...")
        refreshTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, refreshTitle.length))
        refreshTitle.addAttribute(NSFontAttributeName, value: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!, range: NSMakeRange(0, refreshTitle.length))
        refreshControl.attributedTitle = refreshTitle
        
        
        refreshControl.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        tableView.estimatedRowHeight = 109
        tableView.rowHeight = UITableViewAutomaticDimension
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!], forState: UIControlState.Normal)
        
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)
        navigationItem.backBarButtonItem = backButton
        
        
        hideBottomBorder()
    }
    
    
    func hideBottomBorder() {
        for view in navigationController?.navigationBar.subviews.filter({ NSStringFromClass($0.dynamicType) == "_UINavigationBarBackground" }) as [UIView] {
            if let imageView = view.subviews.filter({ $0 is UIImageView }).first as? UIImageView {
                imageView.removeFromSuperview()
            }
        }
    }
    
    func pullToRefresh(){
        view.showLoading()
        loadData()
        tableView.reloadData()
        refreshControl?.endRefreshing()
        
        println("reload finised")
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if timelineFavData.count != 0{
            tableView.backgroundView = nil
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }
        else {
            var imageView = UIImageView(frame: CGRectMake(0, 0, 124, 110))
            view.addSubview(imageView)
            
            
            var imageChosen = UIImage(named: "emptyIconFav")
            imageView.image = imageChosen
            
            tableView.backgroundView = imageView
            // tableView.backgroundColor = UIColorFromRGB(0xECECEC)
            tableView.backgroundView?.contentMode = UIViewContentMode.Center
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return timelineFavData.count
    }

    
    //MARK: Log in delegate
    func loginViewControllerDidLogin(controller: LoginViewController) {
        view.showLoading()
        loadData()
        tabBarController?.tabBar.hidden = false
        
    }
    
    func loginCloseViewControllerDidTouch(controller: LoginViewController) {
        tabBarController?.tabBar.hidden = false
    }
    
    
    //MARK: Create Group delegate
    func createGroupViewControllerDidTouch(controller: CreateGroupViewController) {
        view.showLoading()
        loadData()
        tabBarController?.tabBar.hidden = false
    }
    
    func closeGroupViewControllerDidTouch(controller: CreateGroupViewController) {
        tabBarController?.tabBar.hidden = false
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath) as FavouriteTableViewCell
        
        cell.groupLabel.alpha = 0
        cell.timeLabel.alpha = 0
        cell.groupAvatar.alpha = 0
        cell.timeSign.alpha = 0
        cell.authorSign.alpha = 0
        cell.authorLabel.alpha = 0
        cell.topicSign.alpha = 0
        cell.topicLabel.alpha = 0
        
        let favoriteGroup = self.timelineFavData.objectAtIndex(indexPath.row) as PFObject
        cell.groupLabel.text = favoriteGroup.objectForKey("name") as? String
        cell.timeLabel.text = timeAgoSinceDate(favoriteGroup.createdAt, true)
        
        let groupPic:PFFile = favoriteGroup["groupAvatar"] as PFFile
            
            groupPic.getDataInBackgroundWithBlock{
                (imageData:NSData!, error:NSError!) -> Void in
                
                if error == nil{
                    let image:UIImage = UIImage(data: imageData)!
                    cell.groupAvatar.image = image
                }
            }
            
            var showTopicNo = PFQuery(className: "Topics")
            showTopicNo.whereKey("parent", equalTo: favoriteGroup)
            showTopicNo.countObjectsInBackgroundWithBlock{
                (count: Int32, error: NSError!) -> Void in
                if error == nil {
                    if count <= 1 {
                        cell.topicLabel.text = "\(count) topic"
                    }
                    else{
                        cell.topicLabel.text = "\(count) topics"
                    }
                }
            }
            
            var findUsererData:PFQuery = PFUser.query()
            findUsererData.whereKey("objectId", equalTo: favoriteGroup.objectForKey("userer").objectId)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]!,error:NSError!)->Void in
                
                if (error == nil) {
                    
                    let user:PFUser = (objects as NSArray).lastObject as PFUser
                    cell.authorLabel.text = user.username
                    
                    //final animation
                    spring(1.0){
                        cell.groupLabel.alpha = 1
                        cell.timeLabel.alpha = 1
                        cell.groupAvatar.alpha = 1
                        cell.timeSign.alpha = 1
                        cell.authorSign.alpha = 1
                        cell.authorLabel.alpha = 1
                        cell.topicSign.alpha = 1
                        cell.topicLabel.alpha = 1
                    }

                    
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
