//
//  CommentsTableViewController.swift
//  learningApp
//
//  Created by chinhang on 3/16/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class CommentsTableViewController: PFQueryTableViewController, CommentsTableViewCellDelegate, TopicTableViewCellDelegate,ReplyViewControllerDelegate,UITextViewDelegate {

    var groupCreated : PFObject?
    var topic :PFObject?
    var comment :PFObject?
    var urlTest: String?
    
    let transitionManager = TransitionManager()
    var timelineTopicData:NSMutableArray = NSMutableArray()
    
   
  //  @IBOutlet weak var textView: AutoTextView!
    
    func popToRoot(sender:UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(topic)
  
        refreshControl?.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.estimatedRowHeight = 104
        tableView.rowHeight = UITableViewAutomaticDimension
 
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    
        self.navigationItem.hidesBackButton = true
        
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let title = groupCreated?["name"] as String
        myBackButton.setTitle("  \(title)", forState: UIControlState.Normal)
        myBackButton.setImage(UIImage(named: "perfect"), forState: UIControlState.Normal)
        myBackButton.titleLabel?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 20)

        myBackButton.sizeToFit()
        
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem

    
    }
    func pullToRefresh(){
        view.showLoading()
        self.loadData()
        refreshControl?.endRefreshing()
        self.tableView.reloadData()
        println("reload finised")
        view.hideLoading()
    }
   
 
    
    var isFirstTime = true
    override func viewDidAppear(animated: Bool) {
        
        if isFirstTime {
            self.tableView.setNeedsDisplay()
            self.tableView.layoutIfNeeded()
            self.tableView.reloadData()
            self.loadData()
            isFirstTime = false
        }
        
        navigationController?.navigationBar.topItem?.title = "Comments"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    override init!(style: UITableViewStyle, className: String!) {
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


        findCommentData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                for object in objects {
                    self.timelineCommentData.addObject(object)
                }
                
                let array:NSArray = self.timelineCommentData.reverseObjectEnumerator().allObjects
                self.timelineCommentData = array.mutableCopy() as NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
            }
            else{
                println("no comments")
            }
        })
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
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
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell
        
        if let topicCell = cell as? TopicTableViewCell{
         topicCell.titleLabel.text = topic?.objectForKey("title") as? String
       //  topicCell.contentLabel.text = topic?.objectForKey("content") as? String
            topicCell.contentTextView.text = topic?.objectForKey("content") as? String
         topicCell.timestampLabel.text = timeAgoSinceDate(topic!.createdAt, true)
            
            var findUsererData:PFQuery = PFUser.query()
            findUsererData.whereKey("objectId", equalTo: topic?.objectForKey("userer").objectId)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]!,error:NSError!)->Void in
                
                if (error == nil) {

            
            let user:PFUser! = (objects as NSArray).lastObject as? PFUser!
            
            topicCell.usernameLabel.text = user.username
            
            
    }
                else{
                    println("No username detected")
                }
                
            })
        topicCell.contentTextView.delegate = self
        topicCell.delegate = self
        
        }
        
        if let commentCell = cell as? CommentsTableViewCell {
         let comment:PFObject = self.timelineCommentData.objectAtIndex(indexPath.row - 1) as PFObject

            
        
      //     var getPost = PFQuery(className: "Topics")
        //    var getComment = PFQuery(className: "Comment")
       //     var query = PFQuery(className: "Topics")
      
       //    getPost.whereKey("objectId", equalTo:comment.objectForKey("parent").objectId)
          //  getComment.whereKey("parent", equalTo:PFObject(withoutDataWithClassName: "topic", objectId: "bOX43RTnLW"))
       // getComment.whereKey("parent", matchesQuery: getPost)
     //getComment.includeKey("parent")

      
       // query.whereKey("objectId", equalTo:comment.objectForKey("parent").objectId)
       // query.includeKey("")
//getComment.whereKey("parent", equalTo:PFObject(withoutDataWithClassName: "topic", objectId: "bOX43RTnLW"))
    
            commentCell.commentLabel.text = comment.objectForKey("commentContent") as? String
            commentCell.timeLabel.text = timeAgoSinceDate(comment.createdAt, true)
                    
            var findUsererData:PFQuery = PFUser.query()
            findUsererData.whereKey("objectId", equalTo: topic?.objectForKey("userer").objectId)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]!,error:NSError!)->Void in
                
                if (error == nil) {
                    
                    
                    let user:PFUser! = (objects as NSArray).lastObject as? PFUser!
                    
                    commentCell.authorLabel.text = user.username
                    
                    
                }
                    
                else{
                    println("No username detected")
                }
            
            })
            
            var post = comment["parent"] as PFObject
            
            post.fetchIfNeededInBackgroundWithBlock {
                (post: PFObject!, error: NSError!) -> Void in
                if error == nil{
                    let title = post["title"] as NSString
                    println("\(title)")
                    }
                }

            
        commentCell.delegate = self
        
        }
        
        
        return cell
    }
  // MARK: topic and comment table cell delegate
    func topicTableViewCellDidTouchComment(cell: TopicTableViewCell, sender: AnyObject) {
        performSegueWithIdentifier("replySegue", sender: cell)
        
    }
    
    func topicTableViewCellDidTouchUpvote(cell: TopicTableViewCell, sender: AnyObject) {
    
    }
    
    func commentsTableViewCellDidTouchUpvote(cell: CommentsTableViewCell, sender: AnyObject) {
        
    }
    
    func commentsTableViewCellDidTouchReply(cell: CommentsTableViewCell, sender: AnyObject ){
        performSegueWithIdentifier("replySegue", sender: cell)
        
    }

   // MARK: reply delegate
    func sendReplyDidTouch(controller: ReplyViewController) {
        view.showLoading()
        loadData()
    }
/*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("webSegue", sender: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "replySegue" {
            let toView = segue.destinationViewController as ReplyViewController
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
            let toView = segue.destinationViewController as WebViewController

            if let data = urlTest {
                let escapedString = data.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                let webViewController = WebViewController()
                
                webViewController.urlString = escapedString
                println(escapedString)
                //if let escapedString = escapedString
                toView.urlString = escapedString as String?
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
                toView.transitioningDelegate = transitionManager
                }
        }
        
}
    func textView(textView: UITextView!, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        println("Link Selected!")
        
        println(URL)
        println(URL.absoluteString)
        
        urlTest = URL.absoluteString

        performSegueWithIdentifier("webSegue", sender:self)
        
        return false

     
           }
    
}