//
//  GroupsTableViewController.swift
//  learningApp
//
//  Created by chinhang on 3/13/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class GroupsTableViewController: PFQueryTableViewController, UISearchBarDelegate, LoginViewControllerDelegate, CreateGroupViewControllerDelegate, GroupTableViewCellDelegate {
    

    var groupCreated : PFObject?
    var groupList:NSMutableArray = NSMutableArray()
    var searchActive:Bool = false
    
    
    @IBOutlet weak var signOut: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
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
                alert.title = "Logged out successfully"
                alert.message = ""
                alert.addButtonWithTitle("OK")
                alert.show()
                self.createGroupDidTouch.enabled = false
            }
     
            signOutDialog.addAction(cancelIt)
            signOutDialog.addAction(logOut)
            self.presentViewController(signOutDialog, animated: true, completion: nil)
       

        }
            
        else {
                performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    @IBOutlet weak var createGroupDidTouch: UIBarButtonItem!


    @IBAction func cretateGroupButtonDidTouch(sender: AnyObject) {
        if PFUser.currentUser() == nil{
            performSegueWithIdentifier("loginSegue", sender: self)
            let alert = UIAlertView()
            alert.title = "No user is detected"
            alert.message = "Log in with your account to make comments"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        else{
            performSegueWithIdentifier("createGroupSegue", sender: self)
            
        }
    }
    
    
    override init!(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: "Groups")
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Groups"
        self.pullToRefreshEnabled = false
        self.paginationEnabled = true
        self.objectsPerPage = 50
    }
    
   
    
    func loadGroup(name:String){
        var searchGroup:PFQuery = PFQuery(className: "Groups")
        if !name.isEmpty{
         searchGroup.whereKey("name", containsString: name)
        }
        searchGroup.orderByDescending("createdAt")
        searchGroup.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!) -> Void in
            if error == nil{
                self.groupList = NSMutableArray(array: objects)
                self.tableView.reloadData()
         
            }
        
        })
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        loadGroup(searchText)
        searchActive = true
        
        tableView.reloadData()
        
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if groupList.count == 0{
            searchActive = false
            let alert = UIAlertView()
            alert.title = "Sorry"
            alert.message = "No matching group to display"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
            
        else{
            searchActive = true
        }
        
        searchBar.resignFirstResponder()
        loadObjects()
    }
    

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {

        UIView.animateWithDuration(0.3, animations: {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            self.searchActive = true
            self.loadGroup("00000")
            searchBar.showsCancelButton = true
            self.navigationController?.navigationBarHidden = true
            }, completion: { value in
            
                self.navigationController!.navigationBar.alpha = 0
        })
        return true
}
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchActive = true
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            self.loadGroup("")
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
            searchBar.text = ""
            self.searchActive = false
            //self.tableView.backgroundColor = UIColorFromRGB(0xFFFFFF)
            self.navigationController!.navigationBarHidden = false
            }, completion: { finished in
            
                self.navigationController!.navigationBar.alpha = 1
           
        })
    }
    

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    var timelineGroupData:NSMutableArray = NSMutableArray()
    
    func loadData(){
        if PFUser.currentUser() != nil{
            var findLecturerUser = PFUser.currentUser()
            var scope = findLecturerUser.objectForKey("identity") as Bool?
            if scope == true {
                self.createGroupDidTouch.enabled = true
            }
                
            else {
                self.createGroupDidTouch.enabled = false
            }
            signOut.title = PFUser.currentUser().username
        }
            
        else{
            signOut.title = "Log in"
        }
        tabBarController?.tabBar.hidden = false
        timelineGroupData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findGroupData:PFQuery = PFQuery(className: "Groups")
        findGroupData.orderByAscending("createdAt")
        findGroupData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                for object in objects {
                    self.timelineGroupData.addObject(object)
                }
                
                let array:NSArray = self.timelineGroupData.reverseObjectEnumerator().allObjects
                self.timelineGroupData = array.mutableCopy() as NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            }
        })
    }

    
    
    var isFirstTime = true
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil{
            var findLecturerUser = PFUser.currentUser()
            var scope = findLecturerUser.objectForKey("identity") as Bool?
            if scope == true {
                self.createGroupDidTouch.enabled = true
            }
                
            else {
                self.createGroupDidTouch.enabled = false
            }
           signOut.title = PFUser.currentUser().username
        }

        else{
            signOut.title == "Log in"
            
        }

        if isFirstTime {
            self.view.showLoading()
            self.tableView.setNeedsDisplay()
            self.tableView.layoutIfNeeded()
            self.loadData()
            isFirstTime = false
        }

        //navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.topItem?.title = "Home"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColorFromRGB(0xFFFFFF)
        searchBar.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    textField.attributedPlaceholder =  NSAttributedString(string:NSLocalizedString("Search your group here", comment:""),
                        attributes:[NSForegroundColorAttributeName: UIColorFromRGB(0x9F9C9C), NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 16)!])
                }
            }
        }
        
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

        
      /*  let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            println("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName as String)
            println("Font Names = [\(names)]") */
        
    //  UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
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
        searchActive = false
        loadData()
        tableView.reloadData()
        refreshControl?.endRefreshing()
        
        println("reload finised")
    }
    
    //MARK: Group favorite delegate
    func groupTableViewCellFavoriteDidTouch(cell: GroupTableViewCell, sender: AnyObject) {
        if PFUser.currentUser() != nil{
            let senderButton:UIButton = sender as UIButton
            var groupFav:PFObject = timelineGroupData.objectAtIndex(senderButton.tag) as PFObject
            println(groupFav.objectId)
            
            var objectTo = groupFav.objectForKey("favorite") as Bool?
            if objectTo == true{
                PFUser.currentUser().removeObject(groupFav.objectId, forKey: "favorited")
                PFUser.currentUser().saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                    if success == true {
                        println("remove favorite")
                    } else {
                        println(error)
                    }
                    
                }
                
                groupFav["favorite"] = false
                groupFav.saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                    if success == true {
                        println("remove favorite")
                    } else {
                        println(error)
                    }

            }
                senderButton.setTitle("+ join", forState: UIControlState.Normal)
                senderButton.setTitleColor(UIColorFromRGB(0x56D7CD), forState: UIControlState.Normal)
                senderButton.backgroundColor = UIColorFromRGB(0xFFFFFF)
                
            }
                
            else{
                PFUser.currentUser().addUniqueObject(groupFav.objectId, forKey: "favorited")
                PFUser.currentUser().saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                    if success == true {
                        println("favorited")
                    } else {
                        println(error)
                    }
                    
                    }
                    
                    groupFav["favorite"] = true
                    groupFav.saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                        if success == true {
                            println("favorited")
                        } else {
                            println(error)
                        }
                        
                    }
                
                senderButton.setTitle("Joined", forState: UIControlState.Normal)
                senderButton.setTitleColor(UIColorFromRGB(0xFFFFFF), forState: UIControlState.Normal)
                senderButton.backgroundColor = UIColorFromRGB(0x56D7CD)
                
            }
        }
        
        else {
            performSegueWithIdentifier("loginSegue", sender: self)
        }
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if timelineGroupData.count != 0{
            tableView.backgroundView = nil
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }
        else {
            var imageView = UIImageView(frame: CGRectMake(0, 0, 124, 110))
            view.addSubview(imageView)
            
            var imageChosen = UIImage(named: "emptyIconGroup")
            imageView.image = imageChosen
            
            tableView.backgroundView = imageView
            // tableView.backgroundColor = UIColorFromRGB(0xECECEC)
            tableView.backgroundView?.contentMode = UIViewContentMode.Center
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive == true {
            return groupList.count
        }
        
        return timelineGroupData.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as GroupTableViewCell
        cell.favoriteButton.tag = indexPath.row
       
       if searchActive == true {
        
            let groupCreated:PFObject = self.groupList.objectAtIndex(indexPath.row) as PFObject
            cell.groupName.text = groupCreated.objectForKey("name") as? String
            cell.timeLabel.text = timeAgoSinceDate(groupCreated.createdAt, true) + " ago"
        
        cell.groupName.alpha = 0
        
        cell.timeLabel.alpha = 0
        cell.timeLabelSign.alpha = 0
        
        cell.authorName.alpha = 0
        cell.authorSign.alpha = 0
        cell.avatarGroup.alpha = 0
        
        cell.topicNumber.alpha = 0
        cell.favoriteButton.alpha = 0
        
        let groupAvatar:PFFile = groupCreated["groupAvatar"] as PFFile
        
        groupAvatar.getDataInBackgroundWithBlock{
            (imageData:NSData!, error:NSError!) -> Void in
            
            if error == nil{
                let image:UIImage = UIImage(data: imageData)!
                cell.avatarGroup.image = image
            }
        }
        
        var showTopicNo = PFQuery(className: "Topics")
        showTopicNo.whereKey("parent", equalTo: groupCreated)
        showTopicNo.countObjectsInBackgroundWithBlock{
            (count: Int32, error: NSError!) -> Void in
            if error == nil {
                if count <= 1 {
                cell.topicNumber.setTitle("\(count) topic", forState: UIControlState.Normal)
                }
                else{
                cell.topicNumber.setTitle("\(count) topics", forState: UIControlState.Normal)
                }
            }
        }
        
        var findUsererData:PFQuery = PFUser.query()
        findUsererData.whereKey("objectId", equalTo: groupCreated.objectForKey("userer").objectId)
        
        findUsererData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.authorName.text = user.username
                
                //final animation
                spring(1.0){
                    cell.timeLabel.alpha = 1
                    cell.timeLabelSign.alpha = 1
                    
                    cell.groupName.alpha = 1
                    
                    cell.authorName.alpha = 1
                    cell.authorSign.alpha = 1
                    cell.avatarGroup.alpha = 1
                    
                    cell.topicNumber.alpha = 1
                    cell.favoriteButton.alpha = 1
                }
                
            }
            
        })
        
        var objectTo = groupCreated.objectForKey("favorite") as Bool?
        if objectTo == true{
            
            cell.favoriteButton.setTitle("Joined", forState: UIControlState.Normal)
            cell.favoriteButton.setTitleColor(UIColorFromRGB(0xFFFFFF), forState: UIControlState.Normal)
            cell.favoriteButton.backgroundColor = UIColorFromRGB(0x56D7CD)
        }
        else{
            cell.favoriteButton.setTitle("+ Join", forState: UIControlState.Normal)
            cell.favoriteButton.setTitleColor(UIColorFromRGB(0x56D7CD), forState: UIControlState.Normal)
            cell.favoriteButton.backgroundColor = UIColorFromRGB(0xFFFFFF)
        }


       }
        else {
       
            
        let groupCreated:PFObject = self.timelineGroupData.objectAtIndex(indexPath.row) as PFObject
        cell.groupName.text = groupCreated.objectForKey("name") as? String
        cell.timeLabel.text = timeAgoSinceDate(groupCreated.createdAt, true)
        
      //  cell.groupName.alpha = 0
      //  cell.timeLabel.alpha = 0
      //  cell.authorName.alpha = 0
      
        let groupAvatar:PFFile = groupCreated["groupAvatar"] as PFFile
        
        groupAvatar.getDataInBackgroundWithBlock{
            (imageData:NSData!, error:NSError!) -> Void in
            
            if error == nil{
                let image:UIImage = UIImage(data: imageData)!
                cell.avatarGroup.image = image
            }
        }
        
        var showTopicNo = PFQuery(className: "Topics")
        showTopicNo.whereKey("parent", equalTo: groupCreated)
        showTopicNo.countObjectsInBackgroundWithBlock{
            (count: Int32, error: NSError!) -> Void in
            if error == nil {
                if count <= 1 {
                    cell.topicNumber.setTitle("\(count) topic", forState: UIControlState.Normal)
                }
                else{
                    cell.topicNumber.setTitle("\(count) topics", forState: UIControlState.Normal)
                }
            }
        }
        
        var findUsererData:PFQuery = PFUser.query()
        findUsererData.whereKey("objectId", equalTo: groupCreated.objectForKey("userer").objectId)
        
        findUsererData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.authorName.text = user.username
                
                //final animation
                spring(1.0){
             //       cell.timeLabel.alpha = 1
             //       cell.groupName.alpha = 1
             //       cell.authorName.alpha = 1
                
                }
                
            }

            })
        
        var objectTo = groupCreated.objectForKey("favorite") as Bool?
        if objectTo == true{
            
            cell.favoriteButton.setTitle("Joined", forState: UIControlState.Normal)
            //cell.favoriteButton.titleLabel?.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 14)
            cell.favoriteButton.setTitleColor(UIColorFromRGB(0xFFFFFF), forState: UIControlState.Normal)
            cell.favoriteButton.backgroundColor = UIColorFromRGB(0x56D7CD)
        }
        else{
            cell.favoriteButton.setTitle("+ Join", forState: UIControlState.Normal)
            cell.favoriteButton.setTitleColor(UIColorFromRGB(0x56D7CD), forState: UIControlState.Normal)
            cell.favoriteButton.backgroundColor = UIColorFromRGB(0xFFFFFF)
        }
        }
        cell.delegate = self
        return cell
    }
    
    // MARK: Row Editing
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
    }
   
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: {(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            let deleteMenu = UIAlertController(title: nil, message: "Delete this group?", preferredStyle: .ActionSheet)
            
            let deleteIt = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive)
                { action -> Void in
                    var groupDisplay:PFObject = self.timelineGroupData.objectAtIndex(indexPath.row) as PFObject
                    groupDisplay.deleteInBackground()
                    self.timelineGroupData.removeObjectAtIndex(indexPath.row)
                    groupDisplay.saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                        if success == true {
                            println("deleted")
                        } else {
                            println(error)
                        }
   
            }
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
            let cancelIt = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
                { action -> Void in
            
            }
            
            deleteMenu.addAction(deleteIt)
            deleteMenu.addAction(cancelIt)
            self.presentViewController(deleteMenu, animated: true, completion: nil)
            })
        deleteAction.backgroundColor = UIColorFromRGB(0xD83A31)
        return[deleteAction]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   
        var groupObject:PFObject = timelineGroupData.objectAtIndex(indexPath.row) as PFObject
        if PFUser.currentUser() != nil{
        if groupObject.objectForKey("userer").objectId == PFUser.currentUser().objectId {
       
        return true
    }
        else if groupObject.objectForKey("userer").objectId != PFUser.currentUser().objectId {
            return false
        }
        }
        else {
            return false
        }
    return false
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }

    // MARK: Prepare for segue
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if PFUser.currentUser() == nil{
            let alert = UIAlertView()
            alert.title = "No user is found"
            alert.message = "Log in or sign up an account to browse into groups"
            alert.addButtonWithTitle("OK")
            alert.show()
            performSegueWithIdentifier("loginSegue", sender: self)

        }
        else{
        performSegueWithIdentifier("topicSegue", sender: indexPath)
        }
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "topicSegue"){
            
            var toView = segue.destinationViewController as TopicTableViewController
            toView.hidesBottomBarWhenPushed = true
            if searchActive == true {
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    let row:AnyObject = groupList[indexPath.row]
                    toView.groupCreated = row as? PFObject
                    
                }
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
                  
                    self.searchBar.showsCancelButton = true
                    self.navigationController!.navigationBarHidden = false
                    }, completion: { finished in
                        
                        self.navigationController!.navigationBar.alpha = 1
                        
                })

            }
            else{
                
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let row:AnyObject = timelineGroupData[indexPath.row]
                toView.groupCreated = row as? PFObject
                                }
            }
}
        if (segue.identifier == "createGroupSegue"){
            let toView = segue.destinationViewController as CreateGroupViewController
            tabBarController?.tabBar.hidden = true
            toView.delegate = self
            
        }
        
        if (segue.identifier == "loginSegue"){
            let toView = segue.destinationViewController as LoginViewController
            tabBarController?.tabBar.hidden = true
            toView.delegate = self
            
        }
}
}
