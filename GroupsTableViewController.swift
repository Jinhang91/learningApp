//
//  GroupsTableViewController.swift
//  learningApp
//
//  Created by chinhang on 3/13/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class GroupsTableViewController: PFQueryTableViewController, UISearchBarDelegate {
    

    var groupCreated : PFObject?
    var groupList:NSMutableArray = NSMutableArray()
    var searchActive:Bool = false
    
    
    @IBOutlet weak var signOut: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func signOutButtonDidTouch(sender: AnyObject) {
        
        PFUser.logOut()
        var currentUser = PFUser.currentUser()
        
        
        if currentUser == nil {
            println("Log out successful")
            performSegueWithIdentifier("loginSegue", sender: self)

        }
        else{
            println("Log out failed")
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
        searchActive = true
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchActive = true
        return true
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        loadGroup("")
        searchActive = false
    
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    var timelineGroupData:NSMutableArray = NSMutableArray()
    
    func loadData(){
        timelineGroupData.removeAllObjects()
        
        var findGroupData:PFQuery = PFQuery(className: "Groups")
        
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
            }
        })
    }

    
    
    var isFirstTime = true
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() == nil{
            performSegueWithIdentifier("loginSegue", sender: self)
        }

        
        if isFirstTime {
            self.view.showLoading()
            self.tableView.setNeedsDisplay()
            self.tableView.layoutIfNeeded()
            self.loadData()
           // pullToRefresh()
            isFirstTime = false
        }
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.topItem?.title = "Groups"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    textField.attributedPlaceholder =  NSAttributedString(string:NSLocalizedString("Search your group to join", comment:""),
                        attributes:[NSForegroundColorAttributeName: UIColorFromRGB(0x9F9C9C), NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 16)!])
                }
            }
        }
        
        let cancelButtonAttributes:NSDictionary = [NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 17)!, NSForegroundColorAttributeName:UIColorFromRGB(0x37B8B0)]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes, forState: UIControlState.Normal)
        
        var refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColorFromRGB(0x413D3D)
        refreshControl.tintColor = UIColor.whiteColor()
        
        var refreshTitle:NSMutableAttributedString = NSMutableAttributedString(string: "Refreshing Groups...")
        refreshTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, refreshTitle.length))
        refreshTitle.addAttribute(NSFontAttributeName, value: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!, range: NSMakeRange(0, refreshTitle.length))
        refreshControl.attributedTitle = refreshTitle
        

        refreshControl.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        tableView.estimatedRowHeight = 104
        tableView.rowHeight = UITableViewAutomaticDimension
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)
      // navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)
        
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)
        navigationItem.backBarButtonItem = backButton

        
      /*  let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            println("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName as String)
            println("Font Names = [\(names)]") */
        
       
       //  UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        
        
               }

    func pullToRefresh(){
        view.showLoading()
        loadData()
        tableView.reloadData()
        refreshControl?.endRefreshing()
        
        println("reload finised")
    }
/*
      override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if searchActive == true{
            searchBar = UISearchBar(frame: CGRectMake(0, 0, tableView.frame.size.width, 44))
            searchBar?.delegate = self
            searchBar?.backgroundColor = UIColor(hex: "#EBF0F5")
            searchBar?.searchBarStyle = UISearchBarStyle.Minimal
        }
        
        return searchBar
    }
   
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if searchActive == true {
            
        }
        return 45
    }
*/
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
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

       // let groupCreated:PFObject = self.timelineGroupData.objectAtIndex(indexPath.row) as PFObject
       if searchActive == true {
            
            let groupCreated:PFObject = self.groupList.objectAtIndex(indexPath.row) as PFObject
            cell.groupName.text = groupCreated.objectForKey("name") as? String
            cell.timeLabel.text = timeAgoSinceDate(groupCreated.createdAt, true) + " ago"

        cell.groupName.alpha = 0
        cell.timeLabel.alpha = 0
        cell.authorName.alpha = 0
        
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
                    cell.groupName.alpha = 1
                    cell.authorName.alpha = 1
                }
                
            }
            
        })

       }
        else {
       
            
        let groupCreated:PFObject = self.timelineGroupData.objectAtIndex(indexPath.row) as PFObject
        cell.groupName.text = groupCreated.objectForKey("name") as? String
        cell.timeLabel.text = timeAgoSinceDate(groupCreated.createdAt, true) + " ago"
        
        cell.groupName.alpha = 0
        cell.timeLabel.alpha = 0
        cell.authorName.alpha = 0
      
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
                    cell.groupName.alpha = 1
                    cell.authorName.alpha = 1
                }
                
            }

            })
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("topicSegue", sender: indexPath)
      //  var groupInitial = groupData[indexPath.row]
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "topicSegue"){
            
            var toView = segue.destinationViewController as TopicTableViewController
            if searchActive == true {
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    let row:AnyObject = groupList[indexPath.row]
                    toView.groupCreated = row as? PFObject
                    
                }
            }
            else{
                
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let row:AnyObject = timelineGroupData[indexPath.row]
                toView.groupCreated = row as? PFObject
                 // navigationController?.navigationBar.topItem?.title = groupCreated["name"] as NSString
                }
            }
}
}
}