//
//  TopicTableViewController.swift
//  learningApp
//
//  Created by chinhang on 3/8/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit



class TopicTableViewController: PFQueryTableViewController, TopicTableViewCellDelegate, LoginViewControllerDelegate, ComposeTopicViewControllerDelegate {
    
    var groupCreated:PFObject?
    var topic:PFObject?
    var likeCount:NSArray!
    
    @IBOutlet weak var composeButton: UIBarButtonItem!

    @IBAction func composeButtonDidTouch(sender: AnyObject) {
        if PFUser.currentUser() == nil{
            let alert = UIAlertView()
            alert.title = "No user is detected"
            alert.message = "Log in with your account to create topics"
            alert.addButtonWithTitle("OK")
            alert.show()
            performSegueWithIdentifier("loginTopicSegue", sender: self)
        }
        else{
        performSegueWithIdentifier("composeSegue", sender: self)
        }
        
    }
    

    func popToRoot(sender:UIBarButtonItem){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
  

    override init!(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: "Topics")
    }
    

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
      self.parseClassName = "Topics"
        self.pullToRefreshEnabled = false
       self.paginationEnabled = true
        self.objectsPerPage = 50
    }
    
   var timelineTopicData:NSMutableArray! = NSMutableArray()

   func loadData(){
    if PFUser.currentUser() != nil{
        var findLecturerUser = PFUser.currentUser()
        var scope = findLecturerUser.objectForKey("identity") as Bool?
        if scope == true {
            
            self.composeButton.enabled = true
        }
            
        else {
            
            self.composeButton.enabled = false
        }
        
    }
    
        timelineTopicData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findTopicData:PFQuery = PFQuery(className: "Topics")
    
        findTopicData.whereKey("parent", equalTo: groupCreated!)
        findTopicData.orderByAscending("createdAt")
        findTopicData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                for object in objects {
                    self.timelineTopicData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineTopicData.reverseObjectEnumerator().allObjects
                self.timelineTopicData = array.mutableCopy() as NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
           
            }
        
            else{
                println("no topic")
            }
        })
    }
    
    var isFirstTime = true
    
    override func prefersStatusBarHidden() -> Bool {
        if navigationController?.navigationBarHidden == true {
            return true
        }
        return false
    }
    
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    override func viewDidAppear(animated: Bool) {
  
        if PFUser.currentUser() != nil{
            var findLecturerUser = PFUser.currentUser()
            var scope = findLecturerUser.objectForKey("identity") as Bool?
            if scope == true {
                
                self.composeButton.enabled = true
            }
                
            else {
                
                self.composeButton.enabled = false
            }
            
        }
        if isFirstTime {
        self.view.showLoading()
        self.tableView.setNeedsDisplay()
        self.tableView.layoutIfNeeded()
        self.loadData()
        self.tableView.reloadData()
     
            
       // loginSystem()
        isFirstTime = false
    }
        
        let title = groupCreated?["name"] as String
        
        navigationController?.navigationBar.topItem?.title = "\(title)"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]

            }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(groupCreated)
        refreshControl?.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 96
        tableView.rowHeight = UITableViewAutomaticDimension
      // tableView.rowHeight = 115
        self.navigationItem.hidesBackButton = true
        //let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        //backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!], forState: UIControlState.Normal)
        //navigationItem.backBarButtonItem = backButton
        
        backButton()

        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    func backButton(){
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("  Groups", forState: UIControlState.Normal)
        myBackButton.titleLabel?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 18)
        myBackButton.setImage(UIImage(named: "perfect"), forState: UIControlState.Normal)
        
        myBackButton.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem

    }
    
    func pullToRefresh(){
        loadData()
        tableView.reloadData()
        refreshControl?.endRefreshing()
        println("reload finised")

    }
    

    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if timelineTopicData.count != 0{
            tableView.backgroundView = nil
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }
        else {
            var imageView = UIImageView(frame: CGRectMake(0, 0, 124, 110))
            view.addSubview(imageView)
            
            
            var imageChosen = UIImage(named: "emptyIconTopic")
            imageView.image = imageChosen
            
            tableView.backgroundView = imageView
           // tableView.backgroundColor = UIColorFromRGB(0xECECEC)
            tableView.backgroundView?.contentMode = UIViewContentMode.Center
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        
    return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return timelineTopicData.count
        
        
        }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:TopicTableViewCell = tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath) as TopicTableViewCell

        
        let topic:PFObject = self.timelineTopicData.objectAtIndex(indexPath.row) as PFObject
        cell.titleLabel.text = topic.objectForKey("title") as? String
        
      
        
        //Initial animation
        cell.timestampLabel.alpha = 0
        cell.titleLabel.alpha = 0
        cell.usernameLabel.alpha = 0
        cell.upvoteButton.alpha = 0
        cell.commentButton.alpha = 0
        cell.timeSign.alpha = 0
        cell.authorSign.alpha = 0
        cell.timerButton.alpha = 0
      
        
        //Time setting
        cell.timestampLabel.text = timeAgoSinceDate(topic.createdAt, true)
        
        //Show comment number
        var showCommentNo = PFQuery(className: "Comment")
        showCommentNo.whereKey("parent", equalTo: topic)
        showCommentNo.countObjectsInBackgroundWithBlock{
            (count: Int32, error: NSError!) -> Void in
            if error == nil {
            cell.commentButton.setTitle("\(count)", forState: UIControlState.Normal)
            }
        }
        
        //Show upvote 
       var showTopicLikeNumber = PFUser.query()
        showTopicLikeNumber.whereKey("liked", equalTo: topic.objectId)
        
        showTopicLikeNumber.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil){
                //let liked:NSArray = objects as NSArray
                self.likeCount = objects as NSArray
               cell.upvoteButton.setTitle(toString(self.likeCount.count), forState: UIControlState.Normal)
                              }
            
            })
     
        var objectTo = topic.objectForKey("whoLiked") as [String]
        if contains(objectTo, PFUser.currentUser().objectId){
            
          cell.upvoteButton.setImage(UIImage(named:"icon-upvote-active"), forState: UIControlState.Normal)
                        }
        else{
            cell.upvoteButton.setImage(UIImage(named: "icon-upvote"), forState: UIControlState.Normal)
                        }
        
        var startDate = topic.objectForKey("startingDate") as String!
        var endDate = topic.objectForKey("endingDate") as String!
        
        if startDate == nil && endDate == nil{
            cell.timerButton.setImage(UIImage(named: "timer"), forState: UIControlState.Normal)
        }
            
        else{
            cell.timerButton.setImage(UIImage(named: "timerFill"), forState: UIControlState.Normal)
        }
    

    
        /*
        //show comment enabled 
      
        var commentEnabled:PFQuery = PFQuery(className: "Comment")
        commentEnabled.whereKey("parent", equalTo: topic)
        commentEnabled.whereKey("userer", equalTo: PFUser.currentUser().objectId)
   
        commentEnabled.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!,error:NSError!) ->Void in
            if error == nil{
                cell.commentButton.setImage(UIImage(named: "commentActive"), forState: UIControlState.Normal)
            }
            else{
                cell.commentButton.setImage(UIImage(named: "icon-comment"), forState: UIControlState.Normal)
            }
        }
      */
        cell.upvoteButton.tag = indexPath.row
        cell.commentButton.tag = indexPath.row
        cell.timerButton.tag = indexPath.row
        
        //Username
        var findUsererData:PFQuery = PFUser.query()
        findUsererData.whereKey("objectId", equalTo: topic.objectForKey("userer").objectId)
        
        findUsererData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.usernameLabel.text = user.username
            
                //final animation
                spring(1.0){
                cell.timestampLabel.alpha = 1
                cell.titleLabel.alpha = 1
                cell.usernameLabel.alpha = 1
                cell.commentButton.alpha = 1
                cell.upvoteButton.alpha = 1
                cell.timeSign.alpha = 1
                cell.authorSign.alpha = 1
                cell.timerButton.alpha = 1
                }
              }
        })
        
        var mama = topic["parent"] as PFObject
        
        mama.fetchIfNeededInBackgroundWithBlock {
            (mama: PFObject!, error: NSError!) -> Void in
            if error == nil{
                let title = mama["name"] as NSString
                println("\(title)")
            }
            else{
                println("No group is identifed")
            }
        }
        
        cell.delegate = self
        return cell
    }

    
    // MARK: Compose Topic Delegate
    func submitTopicDidTouch(controller: ComposeTopicViewController) {
        view.showLoading()
        loadData()
    }

    // MARK: LoginViewControllerDelegate
    func loginViewControllerDidLogin(controller: LoginViewController) {
        view.showLoading()
        loadData()
    }
    
    func loginCloseViewControllerDidTouch(controller: LoginViewController) {
        tabBarController?.tabBar.hidden = false
    }
    
    
    
    // MARK: TopicTableViewCellDelegate
   
    var _currentIndexPath:NSIndexPath?
    func topicTableViewCellDidTouchComment(cell: TopicTableViewCell, sender: AnyObject) {
        performSegueWithIdentifier("CommentsSegue", sender: cell)
    }
    
    func topicTableViewCellDidTouchTimer2(cell: TopicTableViewCell, sender: AnyObject) {
        
    }
    
    func topicTableViewCellDIdTouchTimer(cell: TopicTableViewCell, sender: AnyObject) {
        let senderButton:UIButton = sender as UIButton
        var dateInfo:PFObject = timelineTopicData.objectAtIndex(senderButton.tag) as PFObject
        println(dateInfo.objectId)
        
        var startDate = dateInfo.objectForKey("startingDate") as String!
        var endDate = dateInfo.objectForKey("endingDate") as String!
        
        if startDate == nil && endDate == nil{
            let alert = UIAlertView()
            alert.title = "No Date is set yet!"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        
        else{
            let alert = UIAlertView()
            alert.title = "Date"
            alert.message = "Starting Date: \(startDate) \n Ending Date: \(endDate)"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func topicTableViewCellDidTouchUpvote(cell: TopicTableViewCell, sender: AnyObject) {
    
            
        let senderButton:UIButton = sender as UIButton
   
        var topicLiked:PFObject = timelineTopicData.objectAtIndex(senderButton.tag) as PFObject
            println(topicLiked.objectId)
        
           var objectTo = topicLiked.objectForKey("whoLiked") as [String]
           if !contains(objectTo, PFUser.currentUser().objectId){
            
                PFUser.currentUser().addUniqueObject(topicLiked.objectId, forKey: "liked")
                PFUser.currentUser().saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                if success == true {
                    println("liked")
                } else {
                    println(error)
                }
                
            }

                topicLiked.addUniqueObject(PFUser.currentUser().objectId, forKey: "whoLiked")
                topicLiked.saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                if success == true {
                    println("liked")
                } else {
                    println(error)
                }

            }
                senderButton.setImage(UIImage(named: "icon-upvote-active"), forState: UIControlState.Normal)
                senderButton.setTitle(toString(likeCount.count + 1), forState: UIControlState.Normal)
          

            }
           else{
                PFUser.currentUser().removeObject(topicLiked.objectId, forKey: "liked")
                PFUser.currentUser().saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                if success == true {
                    println("like removed")
                } else {
                    println(error)
                }
                
            }

                topicLiked.removeObject(PFUser.currentUser().objectId, forKey: "whoLiked")
                topicLiked.saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                if success == true {
                    println("like removed")
                } else {
                    println(error)
                }
                
            }

            senderButton.setImage(UIImage(named:"icon-upvote"), forState: UIControlState.Normal)
            senderButton.setTitle(toString(likeCount.count), forState: UIControlState.Normal)
         

            }
        
    }
    
    func topicTableViewCellDidTouchUpvote2(cell: TopicTableViewCell, sender: AnyObject) {
        
    }


    // MARK: Prepare for segue
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        println("You select cell #\(indexPath.row)!")
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "CommentsSegue"){
    let toView = segue.destinationViewController as CommentsTableViewController
            let indexPath:AnyObject = tableView.indexPathForCell(sender as UITableViewCell)!
            let topic: AnyObject = timelineTopicData[indexPath.row]

            toView.topic = topic as? PFObject
            toView.index2Path = tableView.indexPathForCell(sender as UITableViewCell)
            toView.groupCreated = groupCreated as PFObject?
            toView.timelineTopicData = timelineTopicData as NSMutableArray!
        }
        
        if (segue.identifier == "composeSegue"){
            let toView = segue.destinationViewController as ComposeTopicViewController
            toView.groupCreated = groupCreated as PFObject?
            toView.delegate = self
        }
        
    }
    
    //MARK: roll editing
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
 
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler:
            {(action: UITableViewRowAction!,indexPath: NSIndexPath!) -> Void in
            
                let deleteMenu = UIAlertController(title: nil, message: "Delete this topic?", preferredStyle: .Alert)
                
                let cancelIt = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
                    { action -> Void in
                        
                }
                
                let deleteIt = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive)
                    { action -> Void in
                        var topicDisplay:PFObject = self.timelineTopicData.objectAtIndex(indexPath.row) as PFObject
                        topicDisplay.deleteInBackground()
                        self.timelineTopicData.removeObjectAtIndex(indexPath.row)

                        topicDisplay.saveInBackgroundWithBlock {(success: Bool!, error: NSError!) -> Void in
                            if success == true {
                                println("deleted")
                            } else {
                                println(error)
                            }
                            
                        }
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                
                deleteMenu.addAction(deleteIt)
                deleteMenu.addAction(cancelIt)
                self.presentViewController(deleteMenu, animated: true, completion: nil)
        })
        deleteAction.backgroundColor = UIColorFromRGB(0x4DB3B7)
        return[deleteAction]
    }
 
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        var topicDisplay:PFObject = self.timelineTopicData.objectAtIndex(indexPath.row) as PFObject
        if topicDisplay.objectForKey("userer").objectId == PFUser.currentUser().objectId{
        return true
        }
    
        return false
    }

}
