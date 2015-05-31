//
//  EvaluationTableViewController.swift
//  learningApp
//
//  Created by chinhang on 4/26/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit


class EvaluationTableViewController: UITableViewController{

    var topic:PFObject?
    var segmentT:UISegmentedControl!
    var timelineTopicData:NSMutableArray! = NSMutableArray()
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func saveButtonDidTouch(sender: AnyObject) {
        let exportMenu = UIAlertController(title: nil, message: "Create PDF and display it", preferredStyle: .ActionSheet)
        
        let createPDF = UIAlertAction(title: "1) Create a PDF file of this data", style: .Default)
         { action -> Void in
        var priorBounds:CGRect = self.tableView.bounds;
        
        var fittedSize:CGSize = self.tableView.sizeThatFits(CGSizeMake(priorBounds.size.width, self.tableView.contentSize.height))
        self.tableView.bounds = CGRectMake(0, 0, fittedSize.width, fittedSize.height);
        
        var pdfPageBounds:CGRect = CGRectMake(0, 0, 768, 1024); // Change this as your need
        var pdfData = NSMutableData()
        
        
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)
        
        for var pageOriginY:CGFloat = 0; pageOriginY < fittedSize.height; pageOriginY += pdfPageBounds.size.height {
            
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil);
            
            CGContextSaveGState(UIGraphicsGetCurrentContext());
            
            CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, -pageOriginY)
            
            self.tableView.layer.renderInContext(UIGraphicsGetCurrentContext())
        }
        
        UIGraphicsEndPDFContext();
        
        self.tableView.bounds = priorBounds; // Reset the tableView
        
        
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        var pdfFileName = path.stringByAppendingPathComponent("Evaluation.pdf")
        
        pdfData.writeToFile(pdfFileName, atomically: true)
        
        println("PDF file is created")
       
        let alert = UIAlertView()
        alert.title = "PDF file is created"
        alert.addButtonWithTitle("OK")
        alert.show()
        }
        
        let displayPDF = UIAlertAction(title: "2) Display the PDF", style: .Default)
            { action -> Void in
        
                self.performSegueWithIdentifier("pdfSegue", sender: self)
        
        }
        
        let cancelIt = UIAlertAction(title: "Cancel", style: .Cancel)
            {
                action -> Void in
        }
        exportMenu.addAction(createPDF)
        exportMenu.addAction(displayPDF)
        exportMenu.addAction(cancelIt)
        
        //the following lines are used in iPad
        if let alertPopver = exportMenu.popoverPresentationController{
            alertPopver.barButtonItem = sender as! UIBarButtonItem
            alertPopver.permittedArrowDirections = UIPopoverArrowDirection.Up
          //  alertPopver.sourceView = sender.view
          //  alertPopver.sourceRect = sender.bounds
        }

        self.presentViewController(exportMenu, animated: true, completion: nil)
    }
    
    @IBOutlet weak var segmentedRating: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationItem.rightBarButtonItem = self.editButtonItem()
        println(topic)

        self.navigationItem.hidesBackButton = true
        tableView.tableFooterView = UIView(frame: CGRectZero)
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        
        myBackButton.setImage(UIImage(named: "perfect"), forState: UIControlState.Normal)
        myBackButton.titleLabel?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 18)
        
        myBackButton.sizeToFit()
        
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        tableView.estimatedRowHeight = 115
        tableView.rowHeight = UITableViewAutomaticDimension

    }
    
    var isFirstTime = true
 
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

    @IBAction func segmentedControlDidTouch(sender: AnyObject) {
        
        switch(self.segmentedRating.selectedSegmentIndex){
        case 0:
            view.showLoading()
            loadData()
            self.tableView.reloadData()
            
        case 1:
            view.showLoading()
            loadExcellentData()
            self.tableView.reloadData()
            
        case 2:
            view.showLoading()
            loadGoodData()
            self.tableView.reloadData()
            
        case 3:
            view.showLoading()
            loadAverageData()
            self.tableView.reloadData()
            
        case 4:
            view.showLoading()
            loadFairData()
            self.tableView.reloadData()
            
        case 5:
            view.showLoading()
            loadPoorData()
            self.tableView.reloadData()
            
        default:
            break
            
        }
        }
    
    
    func popToRoot(sender:UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
         UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    var timelineEvaluatedData:NSMutableArray! = NSMutableArray()
    
    func loadData(){
        timelineEvaluatedData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findEvaluatedData:PFQuery = PFQuery(className: "Comment")
        
       findEvaluatedData.whereKey("parent", equalTo: topic!)
        findEvaluatedData.orderByDescending("createdAt")
        
        findEvaluatedData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?,error:NSError?)->Void in
            
            if (error == nil) {
                for object in objects! {
                    self.timelineEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelineEvaluatedData = array.mutableCopy() as! NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
                
            }
                
            else{
                println("no data")
            }
        })
    }

    var timelineExcellentEvaluatedData:NSMutableArray! = NSMutableArray()
    
    func loadExcellentData(){
        timelineExcellentEvaluatedData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findExcellentEvaluatedData:PFQuery = PFQuery(className: "Comment")
        
        findExcellentEvaluatedData.whereKey("parent", equalTo: topic!)
        findExcellentEvaluatedData.whereKey("rating", equalTo: "excellentRating")
        findExcellentEvaluatedData.orderByDescending("createdAt")
        
        findExcellentEvaluatedData .findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?,error:NSError?)->Void in
            
            if (error == nil) {
                for object in objects! {
                    self.timelineExcellentEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineExcellentEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelineExcellentEvaluatedData = array.mutableCopy() as! NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
                
            }
                
            else{
                println("no data")
            }
        })
    }
    
    var timelineGoodEvaluatedData:NSMutableArray! = NSMutableArray()
    
    func loadGoodData(){
        timelineGoodEvaluatedData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findGoodEvaluatedData:PFQuery = PFQuery(className: "Comment")
        
        findGoodEvaluatedData.whereKey("parent", equalTo: topic!)
        findGoodEvaluatedData.whereKey("rating", equalTo: "goodRating")
        findGoodEvaluatedData.orderByDescending("createdAt")
        
        findGoodEvaluatedData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?,error:NSError?)->Void in
            
            if (error == nil) {
                for object in objects! {
                    self.timelineGoodEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineGoodEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelineGoodEvaluatedData = array.mutableCopy() as! NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
                
            }
                
            else{
                println("no data")
            }
        })
    }
    
    var timelineAveEvaluatedData:NSMutableArray! = NSMutableArray()
    
    func loadAverageData(){
        timelineAveEvaluatedData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findAveEvaluatedData:PFQuery = PFQuery(className: "Comment")
        
        findAveEvaluatedData.whereKey("parent", equalTo: topic!)
        findAveEvaluatedData.whereKey("rating", equalTo: "averageRating")
        findAveEvaluatedData.orderByDescending("createdAt")
        
        findAveEvaluatedData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?,error:NSError?)->Void in
            
            if (error == nil) {
                for object in objects! {
                    self.timelineAveEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineAveEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelineAveEvaluatedData = array.mutableCopy() as! NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
                
            }
                
            else{
                println("no data")
            }
        })
    }

    var timelineFairEvaluatedData:NSMutableArray! = NSMutableArray()
    
    func loadFairData(){
        timelineFairEvaluatedData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findFairEvaluatedData:PFQuery = PFQuery(className: "Comment")
        
        findFairEvaluatedData.whereKey("parent", equalTo: topic!)
        findFairEvaluatedData.whereKey("rating", equalTo: "fairRating")
        findFairEvaluatedData.orderByDescending("createdAt")
        
        findFairEvaluatedData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?,error:NSError?)->Void in
            
            if (error == nil) {
                for object in objects! {
                    self.timelineFairEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineFairEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelineFairEvaluatedData = array.mutableCopy() as! NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
                
            }
                
            else{
                println("no data")
            }
        })
    }
   
    var timelinePoorEvaluatedData:NSMutableArray! = NSMutableArray()
    
    func loadPoorData(){
        timelinePoorEvaluatedData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findPoorEvaluatedData:PFQuery = PFQuery(className: "Comment")
        
        findPoorEvaluatedData.whereKey("parent", equalTo: topic!)
        findPoorEvaluatedData.whereKey("rating", equalTo: "fairRating")
        findPoorEvaluatedData.orderByDescending("createdAt")
        
        findPoorEvaluatedData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?,error:NSError?)->Void in
            
            if (error == nil) {
                for object in objects! {
                    self.timelinePoorEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelinePoorEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelinePoorEvaluatedData = array.mutableCopy() as! NSMutableArray
                
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
       
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedRating.selectedSegmentIndex == 0{
            return timelineEvaluatedData.count + 1
        }
        
        else if segmentedRating.selectedSegmentIndex == 1{
            return timelineExcellentEvaluatedData.count + 1
        }
        
        else if segmentedRating.selectedSegmentIndex == 2{
            return timelineGoodEvaluatedData.count + 1
        }
        
        else if segmentedRating.selectedSegmentIndex == 3{
            return timelineAveEvaluatedData.count + 1
        }
        
        else if segmentedRating.selectedSegmentIndex == 4{
            return timelineFairEvaluatedData.count + 1
        }
        
        else if segmentedRating.selectedSegmentIndex == 5{
            return timelinePoorEvaluatedData.count + 1
        }
            
        else{
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = indexPath.row == 0 ? "topicCell" : "evaluateCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! UITableViewCell
        
        if let topicCell = cell as? TopicTableViewCell{
    
            topicCell.titleLabel.text = topic?.objectForKey("title") as? String
            topicCell.startingDate.text = topic?.objectForKey("startingDate") as? String
            topicCell.endingDate.text = topic?.objectForKey("endingDate") as? String
            
            topicCell.titleLabel.alpha = 0
            topicCell.usernameLabel.alpha = 0
            topicCell.authorSign.alpha = 0
            topicCell.startingDate.alpha = 0
            topicCell.startingLabel.alpha = 0
            topicCell.endingDate.alpha = 0
            topicCell.endingLabel.alpha = 0
            
            
            var findUsererData:PFQuery = PFUser.query()!
            let objectSerial = topic?["userer"] as? PFObject

            findUsererData.whereKey("objectId", equalTo: objectSerial!.objectId!)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil) {
                    
                    
                    let user:PFUser! = (objects! as NSArray).lastObject as? PFUser!
                    
                    topicCell.usernameLabel.text = user.username
                    
                    spring(1.0){
                        topicCell.titleLabel.alpha = 1
                        topicCell.usernameLabel.alpha = 1
                        topicCell.authorSign.alpha = 1
                        topicCell.startingDate.alpha = 1
                        topicCell.startingLabel.alpha = 1
                        topicCell.endingDate.alpha = 1
                        topicCell.endingLabel.alpha = 1
                    }
                    
                    
                }
                else{
                    println("No username detected")
                }
                
            })
            

            
        }
        if let evaluateCell = cell as? EvaluationTableViewCell{
        if segmentedRating.selectedSegmentIndex == 0 {
       
        let evaluatedData:PFObject = self.timelineEvaluatedData.objectAtIndex(indexPath.row - 1) as! PFObject
        evaluateCell.timeLabel.alpha = 0
        evaluateCell.studentMatric.alpha = 0
        evaluateCell.ratingDisplayed.alpha = 0
        
        var rating = evaluatedData.objectForKey("rating") as! String?
        if rating == "poorRating" {
            
            evaluateCell.ratingDisplayed.setImage(UIImage(named:"rating1"), forState: UIControlState.Normal)
            
        }
        
        else if rating == "fairRating" {
            
            evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating2"), forState: UIControlState.Normal)
            
        }
            
        else if rating == "averageRating" {
            
            evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating3"), forState: UIControlState.Normal)
            
        }
            
            
        else if rating == "goodRating" {
            
            evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating4"), forState: UIControlState.Normal)
            
        }
            
        else if rating == "excellentRating" {
            
            evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating5"), forState: UIControlState.Normal)
            
        }
            
        else {
            
            evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
        }

        var findUsererData:PFQuery = PFUser.query()!
        let objectSerial = evaluatedData["userer"] as? PFObject

        findUsererData.whereKey("objectId", equalTo: objectSerial!.objectId!)
        
        findUsererData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?,error:NSError?)->Void in
            
            if (error == nil) {
                
                let user:PFUser = (objects! as NSArray).lastObject as! PFUser
                evaluateCell.studentMatric.text = user.username
                
                //final animation
                spring(1.0){
                    evaluateCell.timeLabel.alpha = 1
                    evaluateCell.studentMatric.alpha = 1
                    evaluateCell.ratingDisplayed.alpha = 1
                }
            }
        })
            
        var dateFormat:NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "dd MMM, yy, HH:mm"
        evaluateCell.timeLabel.text = dateFormat.stringFromDate(evaluatedData.createdAt!)
        }
        
        if segmentedRating.selectedSegmentIndex == 1 {
            
            let evaluatedExcellentData:PFObject = self.timelineExcellentEvaluatedData.objectAtIndex(indexPath.row - 1) as! PFObject
            evaluateCell.timeLabel.alpha = 0
            evaluateCell.studentMatric.alpha = 0
            evaluateCell.ratingDisplayed.alpha = 0
            
            var rating = evaluatedExcellentData.objectForKey("rating") as! String?
            if rating == "excellentRating" {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named:"rating5"), forState: UIControlState.Normal)
                
            }
                
            else {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
            }
            
            var findUsererData:PFQuery = PFUser.query()!
            let objectSerial = evaluatedExcellentData["userer"] as? PFObject

            findUsererData.whereKey("objectId", equalTo: objectSerial!.objectId!)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil) {
                    
                    let user:PFUser = (objects! as NSArray).lastObject as! PFUser
                    evaluateCell.studentMatric.text = user.username
                    
                    //final animation
                    spring(1.0){
                        evaluateCell.timeLabel.alpha = 1
                        evaluateCell.studentMatric.alpha = 1
                        evaluateCell.ratingDisplayed.alpha = 1
                    }
                }
            })
            
            var dateFormat:NSDateFormatter = NSDateFormatter()
            dateFormat.dateFormat = "MMM dd, yyyy, HH:mm"
            evaluateCell.timeLabel.text = dateFormat.stringFromDate(evaluatedExcellentData.createdAt!)
        }
        
        if segmentedRating.selectedSegmentIndex == 2 {
            
            let evaluatedGoodData:PFObject = self.timelineGoodEvaluatedData.objectAtIndex(indexPath.row - 1) as! PFObject
            evaluateCell.timeLabel.alpha = 0
            evaluateCell.studentMatric.alpha = 0
            evaluateCell.ratingDisplayed.alpha = 0
            
            var rating = evaluatedGoodData.objectForKey("rating") as! String?
            if rating == "goodRating" {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named:"rating4"), forState: UIControlState.Normal)
                
            }
                
            else {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
            }
            
            var findUsererData:PFQuery = PFUser.query()!
            let objectSerial = evaluatedGoodData["userer"] as? PFObject

            findUsererData.whereKey("objectId", equalTo: objectSerial!.objectId!)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil) {
                    
                    let user:PFUser = (objects! as NSArray).lastObject as! PFUser
                    evaluateCell.studentMatric.text = user.username
                    
                    //final animation
                    spring(1.0){
                        evaluateCell.timeLabel.alpha = 1
                        evaluateCell.studentMatric.alpha = 1
                        evaluateCell.ratingDisplayed.alpha = 1
                    }
                }
            })
            
            var dateFormat:NSDateFormatter = NSDateFormatter()
            dateFormat.dateFormat = "MMM dd, yyyy, HH:mm"
            evaluateCell.timeLabel.text = dateFormat.stringFromDate(evaluatedGoodData.createdAt!)
        }
        
        if segmentedRating.selectedSegmentIndex == 3 {
            
            let evaluatedAverageData:PFObject = self.timelineAveEvaluatedData.objectAtIndex(indexPath.row - 1) as! PFObject
            evaluateCell.timeLabel.alpha = 0
            evaluateCell.studentMatric.alpha = 0
            evaluateCell.ratingDisplayed.alpha = 0
            
            var rating = evaluatedAverageData.objectForKey("rating") as! String?
                
            if rating == "averageRating" {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating3"), forState: UIControlState.Normal)
                
            }
                
            else {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
            }
            
            var findUsererData:PFQuery = PFUser.query()!
            let objectSerial = evaluatedAverageData["userer"] as? PFObject

            findUsererData.whereKey("objectId", equalTo: objectSerial!.objectId!)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil) {
                    
                    let user:PFUser = (objects! as NSArray).lastObject as! PFUser
                    evaluateCell.studentMatric.text = user.username
                    
                    //final animation
                    spring(1.0){
                        evaluateCell.timeLabel.alpha = 1
                        evaluateCell.studentMatric.alpha = 1
                        evaluateCell.ratingDisplayed.alpha = 1
                    }
                }
            })
            
            var dateFormat:NSDateFormatter = NSDateFormatter()
            dateFormat.dateFormat = "MMM dd, yyyy, HH:mm"
            evaluateCell.timeLabel.text = dateFormat.stringFromDate(evaluatedAverageData.createdAt!)
        }
        
        if segmentedRating.selectedSegmentIndex == 4 {
            
            let evaluatedFairData:PFObject = self.timelineFairEvaluatedData.objectAtIndex(indexPath.row - 1) as! PFObject
            evaluateCell.timeLabel.alpha = 0
            evaluateCell.studentMatric.alpha = 0
            evaluateCell.ratingDisplayed.alpha = 0
            
            var rating = evaluatedFairData.objectForKey("rating") as! String?
            
            if rating == "fairRating" {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating2"), forState: UIControlState.Normal)
                
            }
                
            else {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
            }
            
            var findUsererData:PFQuery = PFUser.query()!
            let objectSerial = evaluatedFairData["userer"] as? PFObject

            findUsererData.whereKey("objectId", equalTo: objectSerial!.objectId!)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil) {
                    
                    let user:PFUser = (objects! as NSArray).lastObject as! PFUser
                    evaluateCell.studentMatric.text = user.username
                    
                    //final animation
                    spring(1.0){
                        evaluateCell.timeLabel.alpha = 1
                        evaluateCell.studentMatric.alpha = 1
                        evaluateCell.ratingDisplayed.alpha = 1
                    }
                }
            })
            
            var dateFormat:NSDateFormatter = NSDateFormatter()
            dateFormat.dateFormat = "MMM dd, yyyy, HH:mm"
            evaluateCell.timeLabel.text = dateFormat.stringFromDate(evaluatedFairData.createdAt!)
        }
        
        if segmentedRating.selectedSegmentIndex == 5 {
            
            let evaluatedPoorData:PFObject = self.timelinePoorEvaluatedData.objectAtIndex(indexPath.row - 1) as! PFObject
            evaluateCell.timeLabel.alpha = 0
            evaluateCell.studentMatric.alpha = 0
            evaluateCell.ratingDisplayed.alpha = 0
            
            var rating = evaluatedPoorData.objectForKey("rating") as! String?
            
            if rating == "fairRating" {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating1"), forState: UIControlState.Normal)
                
            }
                
            else {
                
                evaluateCell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
            }
            
            var findUsererData:PFQuery = PFUser.query()!
            let objectSerial = evaluatedPoorData["userer"] as? PFObject

            findUsererData.whereKey("objectId", equalTo: objectSerial!.objectId!)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?,error:NSError?)->Void in
                
                if (error == nil) {
                    
                    let user:PFUser = (objects! as NSArray).lastObject as! PFUser
                    evaluateCell.studentMatric.text = user.username
                    
                    //final animation
                    spring(1.0){
                        evaluateCell.timeLabel.alpha = 1
                        evaluateCell.studentMatric.alpha = 1
                        evaluateCell.ratingDisplayed.alpha = 1
                    }
                }
            })
            
            var dateFormat:NSDateFormatter = NSDateFormatter()
            dateFormat.dateFormat = "MMM dd, yyyy, HH:mm"
            evaluateCell.timeLabel.text = dateFormat.stringFromDate(evaluatedPoorData.createdAt!)
        }

        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        println("You select cell #\(indexPath.row)!")
    }
    
    
    
    
    /*
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "TTITLE"
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            var evaluateView = UIView(frame: CGRectMake(0, 0, 250, 35))
            evaluateView.backgroundColor = UIColor.clearColor()
            evaluateView.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2)
            //evaluateView.center = self.tableView.center
            
            let items = ["All","Good","Average","Bad"]
            segmentT = UISegmentedControl(items: items)
            segmentT.frame = CGRect(x: 58, y: 10, width: evaluateView.frame.size.width , height: evaluateView.frame.size.height)
            
            segmentT.setWidth(45, forSegmentAtIndex: 0)
            segmentT.setWidth(55, forSegmentAtIndex: 1)
            segmentT.setWidth(65, forSegmentAtIndex: 2)
            segmentT.setWidth(45, forSegmentAtIndex: 3)
            segmentT.selectedSegmentIndex = 0
            
            segmentT.addTarget(self, action: "segmentIndexChanged:", forControlEvents: UIControlEvents.ValueChanged)
            //segmentT.center = CGPointMake(view.frame.size.width / 2 , view.frame.size.height / 2)
            evaluateView.addSubview(segmentT)
            tableView.tableHeaderView = evaluateView
            
            println("pass")
            
            return evaluateView
        }
        return nil
    }
   */
    
    func segmentIndexChanged(sender:UISegmentedControl){
        if segmentT.selectedSegmentIndex == 0{
            println("pass 0")
        }
        else{
                println("others")
            }
    
    }
    
}
