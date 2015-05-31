//
//  CommentsTableViewController.swift
//  learningApp
//
//  Created by chinhang on 3/16/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class CommentsTableViewController: PFQueryTableViewController, CommentsTableViewCellDelegate, TopicTableViewCellDelegate,ReplyViewControllerDelegate,UITextViewDelegate, EditTopicViewControllerDelegate,EditCommentViewControllerDelegate {

    var groupCreated : PFObject?
    var topic :PFObject?
    var comment :PFObject?
    var urlTest: String?
    var realURL:NSURL!
    var likeCount: NSArray!
    let transitionManager = TransitionManager()
    var timelineTopicData:NSMutableArray! = NSMutableArray()
    var index2Path:NSIndexPath!
   
  //  @IBOutlet weak var textView: AutoTextView!
    
    func popToRoot(sender:UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(topic)
        refreshControl?.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
      
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 104
        tableView.rowHeight = UITableViewAutomaticDimension
      //  tableView.rowHeight = 115
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    
        self.navigationItem.hidesBackButton = true
        
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let title = groupCreated?["name"] as! String
        myBackButton.setTitle(" \(title)", forState: UIControlState.Normal)
        myBackButton.setImage(UIImage(named: "perfect"), forState: UIControlState.Normal)
        myBackButton.titleLabel?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 18)

        myBackButton.sizeToFit()
        
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        var evaluateButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        evaluateButton.addTarget(self, action: "evaluateLink:", forControlEvents: UIControlEvents.TouchUpInside)
        
        evaluateButton.setImage(UIImage(named: "evaluate"), forState: UIControlState.Normal)
        evaluateButton.sizeToFit()
        var myCustomRightButtonItem:UIBarButtonItem = UIBarButtonItem(customView: evaluateButton)
        self.navigationItem.rightBarButtonItem  = myCustomRightButtonItem
        
        if PFUser.currentUser() != nil{
            var findLecturerUser = PFUser.currentUser()
            var scope = findLecturerUser!.objectForKey("identity") as! Bool?
            let topicSerial = topic?["userer"] as? PFObject

            if scope == true {
                if topicSerial?.objectId == findLecturerUser?.objectId{
                evaluateButton.enabled = true
                }
                else{
                    evaluateButton.enabled = false
            }
            }
            else {
                
                evaluateButton.enabled = false
            }
            
        }
    }
    
    func evaluateLink(sender:UIBarButtonItem){
        performSegueWithIdentifier("evaluateSegue", sender: self)
    }
    
    func pullToRefresh(){

        loadData()
        tableView.reloadData()
        refreshControl?.endRefreshing()
        println("reload finised")

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
        
        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationController?.navigationBar.topItem?.title = "Comments"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if navigationController?.navigationBarHidden == true {
            return true
        }
        return false
    }
    
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Comment"
        self.pullToRefreshEnabled = false
        self.paginationEnabled = true
        self.objectsPerPage = 50
    }

    var timelineCommentData:NSMutableArray = NSMutableArray()
    
    func loadData() {
        
        timelineCommentData.removeAllObjects()
        
        var findCommentData:PFQuery = PFQuery(className: "Comment")
        
       //findCommentData.whereKey("parent", equalTo:PFObject(withoutDataWithClassName: "Topics", objectId: "bOX43RTnLW"))
       
        findCommentData.whereKey("parent", equalTo: topic!)
        findCommentData.orderByAscending("createdAt")

        findCommentData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?,error:NSError?)->Void in
            
            if (error == nil) {
                for object in objects! {
                    self.timelineCommentData.addObject(object)
                }
                
                let array:NSArray = self.timelineCommentData.reverseObjectEnumerator().allObjects
                self.timelineCommentData = array.mutableCopy() as! NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
            }
            else{
                println("no comments")
            }
        })
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if timelineCommentData.count != 0 && timelineTopicData.count != 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }
        else {
            var imageView = UIImageView(frame: CGRectMake(0, 0, 124, 110))
            view.addSubview(imageView)
            
            
            var imageChosen = UIImage(named: "emptyIconComment")
            imageView.image = imageChosen
            
            tableView.backgroundView = imageView
            // tableView.backgroundColor = UIColorFromRGB(0xECECEC)
            tableView.backgroundView?.contentMode = UIViewContentMode.Center
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return timelineCommentData.count + 1
    
    }
    
    /*
    if let count = comments?.count {
        return count
    }
    return 1
}
*/

    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = indexPath.row == 0 ? "topicCell" : "commentCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        
        if let topicCell = cell as? TopicTableViewCell{
         topicCell.titleLabel.text = topic?.objectForKey("title") as? String
         topicCell.contentTextView.text = topic?.objectForKey("content") as? String
         topicCell.timestampLabel.text = timeAgoSinceDate(topic!.createdAt!, true)
            
         //Initial animation
         topicCell.titleLabel.alpha = 0
         topicCell.contentTextView.alpha = 0
         topicCell.timestampLabel.alpha = 0
         topicCell.usernameLabel.alpha = 0
         topicCell.commentButton.alpha = 0
         topicCell.upvoteButton2.alpha = 0
         topicCell.authorSign.alpha = 0
         topicCell.timeSign.alpha = 0
         topicCell.editedLabel.alpha = 0
         topicCell.timerButton2.alpha = 0
         
         var editedInfo = topic?.objectForKey("edited") as? Bool
            if editedInfo == true{
                topicCell.editedLabel.hidden = false
            }
            else{
                topicCell.editedLabel.hidden = true
            }
            
         var commentNo = PFQuery(className: "Comment")
            commentNo.whereKey("parent", equalTo: topic!)
            commentNo.countObjectsInBackgroundWithBlock{
                (count:Int32, error:NSError?) -> Void in
                if (error == nil){
                    topicCell.commentButton.setTitle("\(count)", forState: UIControlState.Normal)
                }
            }
            
            //Show upvote
            var showTopicLikeNumber = PFUser.query()!
            let topicSerial = topic?["objectId"] as? String
            if let topicObject = topicSerial{
            showTopicLikeNumber.whereKey("liked", equalTo: topicObject)
            
            showTopicLikeNumber.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil){
                    self.likeCount = objects! as NSArray
                    topicCell.upvoteButton2.setTitle(toString(self.likeCount.count), forState: UIControlState.Normal)
                }
                
            })
            }

            var objectTo = topic?.objectForKey("whoLiked") as! [String]
            
            if contains(objectTo, PFUser.currentUser()!.objectId!){
                
                topicCell.upvoteButton2.setImage(UIImage(named:"icon-upvote-active"), forState: UIControlState.Normal)
            }
            else{
                topicCell.upvoteButton2.setImage(UIImage(named: "icon-upvote"), forState: UIControlState.Normal)
            }
            
            var startDate = topic?.objectForKey("startingDate") as! String!
            var endDate = topic?.objectForKey("endingDate") as! String!
            
            if startDate == nil && endDate == nil{
                topicCell.timerButton2.setImage(UIImage(named: "timer"), forState: UIControlState.Normal)
            }
                
            else{
                topicCell.timerButton2.setImage(UIImage(named: "timerFill"), forState: UIControlState.Normal)
            }
            
            //MARK: topic Cell tag for indexPath
            topicCell.upvoteButton2.tag = index2Path.row
            topicCell.timerButton2.tag = index2Path.row
    
            
            var findUsererData:PFQuery = PFUser.query()!
            let topicSeria = topic?["userer"] as? PFObject
            
            findUsererData.whereKey("objectId", equalTo: topicSeria!.objectId!)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil) {

            
            let user:PFUser! = (objects! as NSArray).lastObject as! PFUser!
            
            topicCell.usernameLabel.text = user.username
                  
                    spring(1.0){
                        topicCell.titleLabel.alpha = 1
                        topicCell.contentTextView.alpha = 1
                        topicCell.timestampLabel.alpha = 1
                        topicCell.usernameLabel.alpha = 1
                        topicCell.commentButton.alpha = 1
                        topicCell.upvoteButton2.alpha = 1
                        topicCell.timeSign.alpha = 1
                        topicCell.authorSign.alpha = 1
                        topicCell.editedLabel.alpha = 1
                        topicCell.timerButton2.alpha = 1
                    }
            
            
    }
                else{
                    println("No username detected")
                }
                
            })
            
        topicCell.contentTextView.delegate = self
        topicCell.delegate = self
        
        }
        
        if let commentCell = cell as? CommentsTableViewCell {
         let comment:PFObject = self.timelineCommentData.objectAtIndex(indexPath.row - 1) as! PFObject
            
            if PFUser.currentUser() != nil{
                var findLecturerUser = PFUser.currentUser()
                var topicId = topic?["userer"] as? PFObject
                var scope = findLecturerUser!.objectForKey("identity") as! Bool?
                if scope == true {
                    if topicId?.objectId == findLecturerUser?.objectId{
                    commentCell.evaluateButton.hidden = false
                
                    }
                    else{
                        commentCell.evaluateButton.hidden = true
                    }
                }
                else {
                    
                    commentCell.evaluateButton.hidden = true
                }
                
            }
            
            var editedInfo = comment.objectForKey("edited") as? Bool
            if editedInfo == true{
                commentCell.editedLabel.hidden = false
            }
            else{
                commentCell.editedLabel.hidden = true
            }

    
            commentCell.commentLabel.text = comment.objectForKey("commentContent") as? String
            commentCell.timeLabel.text = timeAgoSinceDate(comment.createdAt!, true)
            
            //Initial Animation
            commentCell.commentLabel.alpha = 0
            commentCell.timeLabel.alpha = 0
            commentCell.upvoteButton.alpha = 0
            commentCell.authorLabel.alpha = 0
            commentCell.evaluateButton.alpha = 0
            commentCell.editedLabel.alpha = 0
            
            //Show upvote
            var showCommentLikeNumber = PFUser.query()!
            showCommentLikeNumber.whereKey("liked", equalTo: comment.objectId!)
            
            showCommentLikeNumber.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil){
                    self.likeCount = objects! as NSArray
                    commentCell.upvoteButton.setTitle("\(self.likeCount.count)", forState: UIControlState.Normal)
                }
                
            })
            
            //likeCommentButton = commentCell.upvoteButton
            var objectTo = comment.objectForKey("whoLiked") as! [String]
            if contains(objectTo, PFUser.currentUser()!.objectId!){
                
                commentCell.upvoteButton.setImage(UIImage(named:"icon-upvote-active"), forState: UIControlState.Normal)
            }
            else{
                commentCell.upvoteButton.setImage(UIImage(named: "icon-upvote"), forState: UIControlState.Normal)
            }
            
            // MARK: evaluateComment
            
            
            var rating = comment.objectForKey("rating") as! String?
            if rating == "poorRating" {
                
                commentCell.evaluateButton.setImage(UIImage(named:"rating1"), forState: UIControlState.Normal)
                
            }
            
            else if rating == "fairRating" {
                
                commentCell.evaluateButton.setImage(UIImage(named: "rating2"), forState: UIControlState.Normal)
               
            }
            
            
            else if rating == "averageRating" {
                
                commentCell.evaluateButton.setImage(UIImage(named: "rating3"), forState: UIControlState.Normal)
                
            }
            
            else if rating == "goodRating"{
                
                commentCell.evaluateButton.setImage(UIImage(named: "rating4"), forState: UIControlState.Normal)
            }
            
            else if rating == "excellentRating"{
                
                commentCell.evaluateButton.setImage(UIImage(named: "rating5"), forState: UIControlState.Normal)
            }
            
            else{
            
                commentCell.evaluateButton.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
            }
            
            //MARK: Comment cell tag for index path
            commentCell.upvoteButton.tag = (indexPath.row - 1)
            commentCell.evaluateButton.tag = (indexPath.row - 1)
            
            var findUsererData:PFQuery = PFUser.query()!
            let commentSer = comment["userer"] as? PFObject
            findUsererData.whereKey("objectId", equalTo: commentSer!.objectId!)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil) {
                    
                    
                    let user:PFUser! = (objects! as NSArray).lastObject as? PFUser!
                    
                    commentCell.authorLabel.text = user.username
                    
                    spring(1.0){
                        commentCell.commentLabel.alpha = 1
                        commentCell.timeLabel.alpha = 1
                        commentCell.upvoteButton.alpha = 1
                        commentCell.evaluateButton.alpha = 1
                        commentCell.authorLabel.alpha = 1
                        commentCell.editedLabel.alpha = 1
                    }
                    
                }
                    
                else{
                    println("No username detected")
                }
            
            })
            /*
            var post = comment["parent"] as! PFObject
            
            post.fetchIfNeededInBackgroundWithBlock {
                (post: PFObject!, error: NSError?) -> Void in
                if error == nil{
                    let title = post["title"] as! NSString
                    println("\(title)")
                    }
                }
*/
            
        commentCell.delegate = self
        
        }
        
        
        return cell
    }
    
    // MARK: Edit topic and comment
    func doneButtonDidTouch(controller: EditTopicViewController) {
        view.showLoading()
        loadData()
    }
    
    func doneButtonCommentDidTouch(controller: EditCommentViewController) {
        view.showLoading()
        loadData()
    }
    
  // MARK: topic and comment table cell delegate
    func topicTableViewCellDIdTouchTimer(cell: TopicTableViewCell, sender: AnyObject) {
        
    }
    
    func topicTableViewCellDidTouchTimer2(cell: TopicTableViewCell, sender: AnyObject) {
        let senderButton:UIButton = sender as! UIButton
        var dateInfo:PFObject = timelineTopicData.objectAtIndex(senderButton.tag) as! PFObject
        println(dateInfo.objectId)
        
        var startDate = dateInfo.objectForKey("startingDate") as! String!
        var endDate = dateInfo.objectForKey("endingDate") as! String!
        
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

    
    func topicTableViewCellDidTouchComment(cell: TopicTableViewCell, sender: AnyObject) {
        performSegueWithIdentifier("replySegue", sender: cell)
        
    }
    
    func topicTableViewCellDidTouchUpvote(cell: TopicTableViewCell, sender: AnyObject) {
      
    }
    
    func topicTableViewCellDidTouchUpvote2(cell: TopicTableViewCell, sender: AnyObject) {
        let senderButton:UIButton = sender as! UIButton
   
        var topicLiked:PFObject = timelineTopicData.objectAtIndex(senderButton.tag) as! PFObject
        println(topicLiked.objectId)
        
        var objectTo = topicLiked.objectForKey("whoLiked") as! [String]
        if !contains(objectTo, PFUser.currentUser()!.objectId!){
            
            PFUser.currentUser()!.addUniqueObject(topicLiked.objectId!, forKey: "liked")
            PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                if success == true {
                    println("liked")
                } else {
                    println(error)
                }
                
            }
            
            topicLiked.addUniqueObject(PFUser.currentUser()!.objectId!, forKey: "whoLiked")
            topicLiked.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
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
            PFUser.currentUser()!.removeObject(topicLiked.objectId!, forKey: "liked")
            PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                if success == true {
                    println("like removed")
                } else {
                    println(error)
                }
                
            }
            
            topicLiked.removeObject(PFUser.currentUser()!.objectId!, forKey: "whoLiked")
            topicLiked.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
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
    
    func commentsTableViewCellDidTouchUpvote(cell: CommentsTableViewCell, sender: AnyObject) {
        let senderButton:SpringButton = sender as! SpringButton
        //   senderButton.addTarget(self, action: "syncLabel:", forControlEvents: UIControlEvents.TouchUpInside)
        var commentLiked:PFObject = timelineCommentData.objectAtIndex(senderButton.tag) as! PFObject
        println(commentLiked.objectId)
        
        var objectTo = commentLiked.objectForKey("whoLiked") as! [String]
        if !contains(objectTo, PFUser.currentUser()!.objectId!){
            
            PFUser.currentUser()!.addUniqueObject(commentLiked.objectId!, forKey: "liked")
            PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                if success == true {
                    println("liked")
                } else {
                    println(error)
                }
                
            }

            commentLiked.addUniqueObject(PFUser.currentUser()!.objectId!, forKey: "whoLiked")
            commentLiked.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
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
            PFUser.currentUser()!.removeObject(commentLiked.objectId!, forKey: "liked")
            PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                if success == true {
                    println("liked removed")
                } else {
                    println(error)
                }
                
            }

            commentLiked.removeObject(PFUser.currentUser()!.objectId!, forKey: "whoLiked")
            commentLiked.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                if success == true {
                    println("liked removed")
                } else {
                    println(error)
                }
                
            }

            senderButton.setImage(UIImage(named:"icon-upvote"), forState: UIControlState.Normal)
            senderButton.setTitle(toString(likeCount.count), forState: UIControlState.Normal)
            
            
        }
        
    }

    
   
    func commentsTableViewCellDidTouchEvaluate(cell: CommentsTableViewCell, sender: AnyObject ){
        let senderButton:SpringButton = sender as! SpringButton
        var commentEvaluated:PFObject = timelineCommentData.objectAtIndex(senderButton.tag) as! PFObject
        var rating = commentEvaluated.objectForKey("rating") as! String?
        let rateMenu = UIAlertController(title: nil, message: "Rate this comment", preferredStyle: .ActionSheet)
        
        //var excellentRating: UIAlertAction!
        if rating == "excellentRating"{
        let editRating = UIAlertController(title: nil, message: "Are you sure to remove this comment's rating?", preferredStyle: .Alert)
            let cancelIt = UIAlertAction(title: "Cancel", style: .Cancel)
                {
                    action -> Void in
            }
            
            let reRate = UIAlertAction(title: "Yes", style: .Default)
                {
                    action -> Void in

                    PFUser.currentUser()!.removeObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = ""
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    senderButton.setImage(UIImage(named:"rating"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
            }
            
            editRating.addAction(cancelIt)
            editRating.addAction(reRate)
            self.presentViewController(editRating, animated: true, completion: nil)
        }
        else{
                let excellentRating = UIAlertAction(title: "Excellent", style: .Default)
                { action -> Void in
                    PFUser.currentUser()!.addUniqueObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = "excellentRating"
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    senderButton.setImage(UIImage(named:"rating5"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
    }
            rateMenu.addAction(excellentRating)
    }
        
      //  var goodRating: UIAlertAction!
        if rating == "goodRating"{
            let editRating = UIAlertController(title: nil, message: "Are you sure to remove this comment's rating?", preferredStyle: .Alert)
            let cancelIt = UIAlertAction(title: "Cancel", style: .Cancel)
                {
                    action -> Void in
            }
            
            let reRate = UIAlertAction(title: "Yes", style: .Default)
                {
                    action -> Void in
                    
                    PFUser.currentUser()!.removeObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = ""
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    senderButton.setImage(UIImage(named:"rating"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
            }
            
            editRating.addAction(cancelIt)
            editRating.addAction(reRate)
            self.presentViewController(editRating, animated: true, completion: nil)
        }
        else{
            let goodRating = UIAlertAction(title: "Good", style: .Default)
                { action -> Void in
                    PFUser.currentUser()!.addUniqueObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = "goodRating"
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    senderButton.setImage(UIImage(named:"rating4"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
            }
            
            rateMenu.addAction(goodRating)
        }
        
     //   var averageRating: UIAlertAction!
        if rating == "averageRating"{
            let editRating = UIAlertController(title: nil, message: "Are you sure to remove this comment's rating?", preferredStyle: .Alert)
            let cancelIt = UIAlertAction(title: "Cancel", style: .Cancel)
                {
                    action -> Void in
            }
            
            let reRate = UIAlertAction(title: "Yes", style: .Default)
                {
                    action -> Void in
                    
                    PFUser.currentUser()!.removeObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = ""
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    senderButton.setImage(UIImage(named:"rating"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
            }
            
            editRating.addAction(cancelIt)
            editRating.addAction(reRate)
            self.presentViewController(editRating, animated: true, completion: nil)
        }
        else{
            let averageRating = UIAlertAction(title: "Average", style: .Default)
                { action -> Void in
                    PFUser.currentUser()!.addUniqueObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = "averageRating"
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    senderButton.setImage(UIImage(named:"rating3"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
            }
            
            rateMenu.addAction(averageRating)
        }

        
      //  var fairRating: UIAlertAction!
        if rating == "fairRating"{
            let editRating = UIAlertController(title: nil, message: "Are you sure to remove this comment's rating?", preferredStyle: .Alert)
            let cancelIt = UIAlertAction(title: "Cancel", style: .Cancel)
                {
                    action -> Void in
            }
            
            let reRate = UIAlertAction(title: "Yes", style: .Default)
                {
                    action -> Void in
                    
                    PFUser.currentUser()!.removeObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = ""
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    senderButton.setImage(UIImage(named:"rating"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
            }
            
            editRating.addAction(cancelIt)
            editRating.addAction(reRate)
            self.presentViewController(editRating, animated: true, completion: nil)
        }
        else{
            let fairRating = UIAlertAction(title: "Fair", style: .Default)
                { action -> Void in
                    PFUser.currentUser()!.addUniqueObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = "fairRating"
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    senderButton.setImage(UIImage(named:"rating2"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
            }
            
            rateMenu.addAction(fairRating)
        }

     //   var poorRating: UIAlertAction!
        if rating == "poorRating"{
            let editRating = UIAlertController(title: nil, message: "Are you sure to remove this comment's rating?", preferredStyle: .Alert)
            let cancelIt = UIAlertAction(title: "Cancel", style: .Cancel)
                {
                    action -> Void in
            }
            
            let reRate = UIAlertAction(title: "Yes", style: .Default)
                {
                    action -> Void in
                    
                    PFUser.currentUser()!.removeObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = ""
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("remove rating")
                        } else {
                            println(error)
                        }
                        
                    }
                    senderButton.setImage(UIImage(named:"rating"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
            }
            
            editRating.addAction(cancelIt)
            editRating.addAction(reRate)
            self.presentViewController(editRating, animated: true, completion: nil)
        }
        else{
            let poorRating = UIAlertAction(title: "Poor", style: .Default)
                { action -> Void in
                    PFUser.currentUser()!.addUniqueObject(commentEvaluated.objectId!, forKey: "evaluated")
                    PFUser.currentUser()!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    commentEvaluated["rating"] = "poorRating"
                    commentEvaluated.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if success == true {
                            println("evaluated")
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    senderButton.setImage(UIImage(named:"rating1"), forState: UIControlState.Normal)
                    senderButton.setTitle("", forState: UIControlState.Normal)
                    
            }
            
            rateMenu.addAction(poorRating)
        }

        let cancelRating = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        rateMenu.addAction(cancelRating)
        
        
        //the following lines are used in iPad
        if let alertPopver:UIPopoverPresentationController = rateMenu.popoverPresentationController{
        alertPopver.sourceView = cell.evaluateButton
       // rateMenu.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
            alertPopver.sourceRect = cell.evaluateButton.bounds
        }
        self.presentViewController(rateMenu, animated: true, completion: nil)
        
    }
    
   // MARK: reply delegate
    func sendReplyDidTouch(controller: ReplyViewController) {
        view.showLoading()
        loadData()
    }

    // MARK: prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "replySegue" {
            let toView = segue.destinationViewController as! ReplyViewController
            if let cell = sender as? CommentsTableViewCell {
               let indexPath = tableView.indexPathForCell(cell)!
               let comments: AnyObject = timelineCommentData[indexPath.row - 1]
                
                toView.comment = comments as? PFObject
            }
        
            if let cell = sender as? TopicTableViewCell {
               
                toView.topic = topic as PFObject?
                toView.delegate = self
            }
        }


        if segue.identifier == "webSegue"{
            let toView = segue.destinationViewController as! WebViewController

            if let data = urlTest {
                let escapedString = data.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                let webViewController = WebViewController()
                
                webViewController.urlString = escapedString
                //println(escapedString)
                toView.urlString = escapedString as String?
                toView.realURL = realURL as NSURL!
                
                toView.transitioningDelegate = transitionManager
                }
        }
        
        if segue.identifier == "evaluateSegue"{
            let toView = segue.destinationViewController as! EvaluationTableViewController
            toView.topic = topic as PFObject?
            toView.timelineTopicData = timelineTopicData as NSMutableArray!
        }
        
        if (segue.identifier == "editTopicSegue"){
            let toView = segue.destinationViewController as! EditTopicViewController
            toView.objectTo = topic as PFObject?
            toView.delegate = self
            }
            
  
        
        
        if segue.identifier == "editCommentSegue"{
            let toView = segue.destinationViewController as! EditCommentViewController
            if let indexPath:AnyObject = sender{
            let row:AnyObject = timelineCommentData[indexPath.row - 1]
            toView.objectTo = row as? PFObject
            toView.delegate = self
            }
        }
}
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        println("Link Selected!")
        
        println(URL)
        println(URL.absoluteString)
        realURL = URL
        urlTest = URL.absoluteString

        performSegueWithIdentifier("webSegue", sender:self)
        
        return false

     
           }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        println("You select cell #\(indexPath.row)!")
    }
    
    //MARK: roll editing
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    deinit
    {
     tableView.editing = false
        // perform the deinitialization
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {

        let editAction = UITableViewRowAction(style: .Default, title: "Edit", handler:
            {(action: UITableViewRowAction!,indexPath: NSIndexPath!) -> Void in
                
                let editMenu = UIAlertController(title: nil, message: "Edit this?", preferredStyle: .Alert)
                
                let cancelIt = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
                    { action -> Void in
                        
                }
                
                let editIt = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive)
                    { action -> Void in
                       
                        if indexPath.row == 0{
                        self.performSegueWithIdentifier("editTopicSegue", sender: indexPath)
                        }
                        
                        else{
                            self.performSegueWithIdentifier("editCommentSegue", sender: indexPath)
                        }
                }
                
                editMenu.addAction(editIt)
                editMenu.addAction(cancelIt)
                self.presentViewController(editMenu, animated: true, completion: nil)
        })

        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler:
            {(action: UITableViewRowAction!,indexPath: NSIndexPath!) -> Void in
                
                let deleteMenu = UIAlertController(title: nil, message: "Delete this comment?", preferredStyle: .Alert)
                
                let cancelIt = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
                    { action -> Void in
                        
                }
                
                let deleteIt = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive)
                    { action -> Void in
                        var commentDisplay:PFObject = self.timelineCommentData.objectAtIndex(indexPath.row - 1) as! PFObject
                        commentDisplay.deleteInBackground()
                        self.timelineCommentData.removeObjectAtIndex(indexPath.row - 1)
                        commentDisplay.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
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
        
        editAction.backgroundColor = UIColorFromRGB(0x4FD7CE)
        deleteAction.backgroundColor = UIColorFromRGB(0x4DB3B7)
       
       
        if indexPath.row >= 1 {
            var commentDisplay:PFObject = self.timelineCommentData.objectAtIndex(indexPath.row - 1) as! PFObject
         //   let commentSerial = commentDisplay["userer"] as? String
            
            if topic?.objectForKey("userer")!.objectId == PFUser.currentUser()!.objectId {
            return [deleteAction]
            }
            
            else if commentDisplay.objectForKey("userer")?.objectId == PFUser.currentUser()!.objectId {
                return [deleteAction,editAction]
            }

            else {
                return nil
            }
            }
        
        
        
        else if indexPath.row == 0 {
  
            if topic?.objectForKey("userer")!.objectId == PFUser.currentUser()!.objectId {
            return[editAction]
        }
            else{
                return nil
            }
        }
        
            return nil
        
       
    }
    

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let topicSerial = topic?["userer"] as? PFObject
        if indexPath.row == 0 && topic?.objectForKey("userer")!.objectId == PFUser.currentUser()!.objectId{
            return true
        }
        
        if indexPath.row >= 1{
            var comment:PFObject = self.timelineCommentData.objectAtIndex(indexPath.row - 1) as! PFObject

            if comment.objectForKey("userer")!.objectId == PFUser.currentUser()!.objectId{
                return true
            }
            
            else if topicSerial?.objectId == PFUser.currentUser()!.objectId{
                return true
            }
            return false
        }
            
        else{
            return false
        }
}
    
}