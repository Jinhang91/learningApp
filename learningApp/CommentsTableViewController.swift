//
//  CommentsTableViewController.swift
//  learningApp
//
//  Created by chinhang on 3/16/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class CommentsTableViewController: PFQueryTableViewController, CommentsTableViewCellDelegate, TopicTableViewCellDelegate {


   var topic :PFObject?
    var comment :PFObject?
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        println(topic)
        refreshControl?.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
         navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Gill Sans", size: 19)!], forState: UIControlState.Normal)
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    
        //  tableView.rowHeight = 125
    
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
         topicCell.contentLabel.text = topic?.objectForKey("content") as? String
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
            }
        }
    }
}
