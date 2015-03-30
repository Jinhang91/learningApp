//
//  TopicTableViewController.swift
//  learningApp
//
//  Created by chinhang on 3/8/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit



class TopicTableViewController: PFQueryTableViewController, TopicTableViewCellDelegate {
    var groupCreated:PFObject?
   
   // @IBOutlet weak var signOutButton: UIBarButtonItem!
    @IBOutlet weak var composeButton: UIBarButtonItem!
  /*
    @IBAction func signOutButtonDidPress(sender: AnyObject) {
   
    PFUser.logOut()
        var currentUser = PFUser.currentUser()
        if currentUser == nil {
        println("Log out successful")
        }
       else{
        println("Log out failed")
        }
    loginSystem()
    
    }
    */
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
    
   var timelineTopicData:NSMutableArray = NSMutableArray()

   func loadData(){
        timelineTopicData.removeAllObjects()
    
        var findTopicData:PFQuery = PFQuery(className: "Topics")
    
        findTopicData.whereKey("parent", equalTo: groupCreated!)
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
    
    override func viewDidAppear(animated: Bool) {
       // loadData()
        if isFirstTime {
        self.view.showLoading()
        self.tableView.setNeedsDisplay()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        self.loadData()
            
       // loginSystem()
        isFirstTime = false
    }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(groupCreated)
        refreshControl?.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Gill Sans", size: 19)!], forState: UIControlState.Normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Gill Sans", size: 19)!], forState: UIControlState.Normal)
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    func pullToRefresh(){
        view.showLoading()
        self.loadData()
        refreshControl?.endRefreshing()
        self.tableView.reloadData()
        println("reload finised")
        view.hideLoading()
    }
    
    /*
    func loginSystem(){
        
        if PFUser.currentUser() == nil
        {
            var loginAlert:UIAlertController = UIAlertController(title: "Sign Up/ Sign In", message: "Please sign up or log in", preferredStyle: UIAlertControllerStyle.Alert)
            
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Matric No."
            })
            
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Password"
                textfield.secureTextEntry = true
            })
            
            loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler:{
                alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let matricTextField:UITextField = textFields.objectAtIndex(0) as UITextField
                let passwordTextField:UITextField = textFields.objectAtIndex(1) as UITextField
                
                PFUser.logInWithUsernameInBackground(matricTextField.text, password: passwordTextField.text)
                    {
                        (user:PFUser!, error:NSError!)->Void in
                        if user != nil
                        {
                            println("Login successful")
                            self.loadData()
                        }
                        else
                        {
                            println("Login failed")
                        }
                }
                
                
                
            }  ))
            
            loginAlert.addAction(UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.Default, handler:{
                alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let matricTextField:UITextField = textFields.objectAtIndex(0) as UITextField
                let passwordTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
                
                var userer:PFUser = PFUser()
                userer.username = matricTextField.text
                userer.password = passwordTextfield.text
                passwordTextfield.secureTextEntry = true
                
                userer.signUpInBackgroundWithBlock{
                    (success:Bool!, error:NSError!)->Void in
                    if !(error != nil){
                        println("Sign Up Successful")
                    }else{
                        let errorString = error.userInfo!["error"] as String
                        println(errorString)
                    }
                }
                
            }))
            
            self.presentViewController(loginAlert, animated: true, completion: nil)
            
        }
        
    }
    */


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        //// change to one, only have one section
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return timelineTopicData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:TopicTableViewCell = tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath) as TopicTableViewCell

        
        let topic:PFObject = self.timelineTopicData.objectAtIndex(indexPath.row) as PFObject
        cell.titleLabel.text = topic.objectForKey("title") as? String
        cell.contentLabel.text = topic.objectForKey("content") as? String
       // cell.content2Label.text = topic.objectForKey("content") as String
        
        //Initial animation
        cell.timestampLabel.alpha = 0
        cell.contentLabel.alpha = 0
        cell.titleLabel.alpha = 0
        cell.usernameLabel.alpha = 0
        
        //Time setting
        cell.timestampLabel.text = timeAgoSinceDate(topic.createdAt, true)
        
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
                cell.contentLabel.alpha = 1
                cell.titleLabel.alpha = 1
                cell.usernameLabel.alpha = 1
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

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // performSegueWithIdentifier("webSegue", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
   println("You select cell #\(indexPath.row)!")
    }

    
  
    // MARK: TopicTableViewCellDelegate
   
    func topicTableViewCellDidTouchUpvote(cell: TopicTableViewCell, sender: AnyObject) {
        
    }

    func topicTableViewCellDidTouchComment(cell: TopicTableViewCell, sender: AnyObject) {
        if PFUser.currentUser() == nil {
            let alert = UIAlertView()
            alert.title = "No user is detected"
            alert.message = "Log in with your account to make comments"
            alert.addButtonWithTitle("OK")
            alert.show()
            performSegueWithIdentifier("loginTopicSegue", sender: self)
        }
        else {
            performSegueWithIdentifier("CommentsSegue", sender: cell)
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "CommentsSegue"){
    let toView = segue.destinationViewController as CommentsTableViewController
    let indexPath = tableView.indexPathForCell(sender as UITableViewCell)!
            let topic: AnyObject = timelineTopicData[indexPath.row]
            toView.topic = topic as? PFObject
        
        }
        
        if (segue.identifier == "composeSegue"){
            let toView = segue.destinationViewController as ComposeTopicViewController
            toView.groupCreated = groupCreated as PFObject?
        }
    }
 }
