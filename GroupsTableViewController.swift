//
//  GroupsTableViewController.swift
//  learningApp
//
//  Created by chinhang on 3/13/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class GroupsTableViewController: PFQueryTableViewController, UISearchBarDelegate, LoginViewControllerDelegate, CreateGroupViewControllerDelegate, GroupTableViewCellDelegate{
    

    var groupCreated : PFObject?
    var groupList:NSMutableArray = NSMutableArray()
    var searchActive:Bool = false
    var window: UIWindow?
    
    @IBOutlet weak var signOut: UIBarButtonItem!
    
   // @IBOutlet weak var searchBar: UISearchBar!
    var searchBar: UISearchBar!

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

            searchActive = true
            loadGroup("0000")
            searchBar.showsCancelButton = true
            return true
}
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchActive = true
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    
            self.loadGroup("")
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
            searchBar.text = ""
            self.searchActive = false
    }
    

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    var timelineGroupData:NSMutableArray = NSMutableArray()
    
    func loadData(){

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
        if isFirstTime {
            self.tableView.setNeedsDisplay()
            self.tableView.layoutIfNeeded()
            self.loadData()
            self.tableView.reloadData()
            isFirstTime = false
        }
        navigationController?.navigationBar.topItem?.title = "Search"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
       // navigationController?.hidesBarsOnSwipe = true
    }

    override func prefersStatusBarHidden() -> Bool {
        if navigationController?.navigationBarHidden == true{
        return true
        }
        return false
    }
  
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar = UISearchBar(frame: CGRectMake(0, 0, 320, 44))
        navigationItem.titleView = searchBar

        var textField = searchBar.valueForKey("searchField") as UITextField
        textField.backgroundColor = UIColorFromRGB(0xE3E4E6)
        
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColorFromRGB(0xF8F8F8).CGColor

        tableView.backgroundColor = UIColorFromRGB(0xFFFFFF)
        searchBar.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    textField.attributedPlaceholder =  NSAttributedString(string:NSLocalizedString("Search your group to join", comment:""),
                        attributes:[NSForegroundColorAttributeName: UIColorFromRGB(0x9F9C9C), NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 16)!])
                }
            }
        }
        
        let cancelButtonAttributes:NSDictionary = [NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 17)!, NSForegroundColorAttributeName:UIColorFromRGB(0x000000)]
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
        searchActive = false
        loadData()
        tableView.reloadData()
        refreshControl?.endRefreshing()
        
        println("reload finised")
    }
    
    //MARK: Group favorite delegate
    func groupTableViewCellFavoriteDidTouch(cell: GroupTableViewCell, sender: AnyObject) {
        
            let senderButton:UIButton = sender as UIButton
        if PFUser.currentUser() != nil{
        if searchActive == false{
            var groupFav:PFObject = timelineGroupData.objectAtIndex(senderButton.tag) as PFObject
            println(groupFav.objectId)
            
            var objectTo = groupFav.objectForKey("whoFavorited") as [String]
            if contains(objectTo, PFUser.currentUser().objectId){
                PFUser.currentUser().removeObject(groupFav.objectId, forKey: "favorited")
                PFUser.currentUser().saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                    if success == true {
                        println("remove favorite")
                    } else {
                        println(error)
                    }
                    
                }
                
                groupFav.removeObject(PFUser.currentUser().objectId, forKey: "whoFavorited")
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
                    
                    groupFav.addUniqueObject(PFUser.currentUser().objectId, forKey: "whoFavorited")
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
        else{
            var groupSearched:PFObject = groupList.objectAtIndex(senderButton.tag) as PFObject
            println(groupSearched.objectId)
            
            var objectTo = groupSearched.objectForKey("whoFavorited") as [String]
            if contains(objectTo, PFUser.currentUser().objectId){
                PFUser.currentUser().removeObject(groupSearched.objectId, forKey: "favorited")
                PFUser.currentUser().saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                    if success == true {
                        println("remove favorite")
                    } else {
                        println(error)
                    }
                    
                }
                
                groupSearched.removeObject(PFUser.currentUser().objectId, forKey: "whoFavorited")
                groupSearched.saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
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
                PFUser.currentUser().addUniqueObject(groupSearched.objectId, forKey: "favorited")
                PFUser.currentUser().saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                    if success == true {
                        println("favorited")
                    } else {
                        println(error)
                    }
                    
                }
                
                groupSearched.addUniqueObject(PFUser.currentUser().objectId, forKey: "whoFavorited")
                groupSearched.saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
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
        }
        else{
            let alert = UIAlertView()
            alert.title = "No user is detected"
            alert.message = "Log in /sign up your account to join a group"
            alert.addButtonWithTitle("OK")
            alert.show()
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
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
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

        cell.favoriteButton.alpha = 0
        
        let groupAvatar:PFFile = groupCreated["groupAvatar"] as PFFile
        
        groupAvatar.getDataInBackgroundWithBlock{
            (imageData:NSData!, error:NSError!) -> Void in
            
            if error == nil{
                let image:UIImage = UIImage(data: imageData)!
                cell.avatarGroup.image = image
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
                    cell.favoriteButton.alpha = 1
                }
                
            }
            
        })
        if PFUser.currentUser() != nil{
        var objectTo = groupCreated.objectForKey("whoFavorited") as [String]
        if contains(objectTo, PFUser.currentUser().objectId){
            
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
        
        let groupAvatar:PFFile = groupCreated["groupAvatar"] as PFFile
        
        groupAvatar.getDataInBackgroundWithBlock{
            (imageData:NSData!, error:NSError!) -> Void in
            
            if error == nil{
                let image:UIImage = UIImage(data: imageData)!
                cell.avatarGroup.image = image
            }
        }

        var findUsererData:PFQuery = PFUser.query()
        findUsererData.whereKey("objectId", equalTo: groupCreated.objectForKey("userer").objectId)
        
        findUsererData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.authorName.text = user.username
                
            }

            })
        if PFUser.currentUser() != nil{
        var objectTo = groupCreated.objectForKey("whoFavorited") as [String]
        if contains(objectTo, PFUser.currentUser().objectId){
            
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
        deleteAction.backgroundColor = UIColorFromRGB(0x4DB3B7)
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
      
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "loginSegue"){
            let toView = segue.destinationViewController as LoginViewController
            tabBarController?.tabBar.hidden = true
            toView.delegate = self
            
        }
}
}
