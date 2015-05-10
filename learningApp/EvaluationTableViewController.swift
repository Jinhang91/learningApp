//
//  EvaluationTableViewController.swift
//  learningApp
//
//  Created by chinhang on 4/26/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class EvaluationTableViewController: UITableViewController {

    var topic:PFObject?
    var segmentT:UISegmentedControl!
    
    @IBAction func saveButtonDidTouch(sender: AnyObject) {
        var priorBounds:CGRect = self.tableView.bounds;
        
        var fittedSize:CGSize = self.tableView.sizeThatFits(CGSizeMake(priorBounds.size.width, self.tableView.contentSize.height))
        self.tableView.bounds = CGRectMake(0, 0, fittedSize.width, fittedSize.height);
        
        var pdfPageBounds:CGRect = CGRectMake(0, 0, 320, 568); // Change this as your need
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
        
        
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        var pdfFileName = path.stringByAppendingPathComponent("testfilewnew.pdf")
        
        pdfData.writeToFile(pdfFileName, atomically: true)
    }
    
    @IBOutlet weak var segmentedRating: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationItem.rightBarButtonItem = self.editButtonItem()
        println(topic)

        self.navigationItem.hidesBackButton = true
        tableView.tableFooterView = UIView(frame: CGRectZero)
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        
        myBackButton.setImage(UIImage(named: "perfect"), forState: UIControlState.Normal)
        myBackButton.titleLabel?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 18)
        
        myBackButton.sizeToFit()
        
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        tableView.estimatedRowHeight = 53
        tableView.rowHeight = UITableViewAutomaticDimension

        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
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
            loadGoodData()
            self.tableView.reloadData()
            
        case 2:
            view.showLoading()
            loadAveData()
            self.tableView.reloadData()
            
        case 3:
            view.showLoading()
            loadBadData()
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
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                for object in objects {
                    self.timelineEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelineEvaluatedData = array.mutableCopy() as NSMutableArray
                
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
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                for object in objects {
                    self.timelineGoodEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineGoodEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelineGoodEvaluatedData = array.mutableCopy() as NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
                
            }
                
            else{
                println("no data")
            }
        })
    }
    
    var timelineAveEvaluatedData:NSMutableArray! = NSMutableArray()
    
    func loadAveData(){
        timelineAveEvaluatedData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findAveEvaluatedData:PFQuery = PFQuery(className: "Comment")
        
        findAveEvaluatedData.whereKey("parent", equalTo: topic!)
        findAveEvaluatedData.whereKey("rating", equalTo: "averageRating")
        findAveEvaluatedData.orderByDescending("createdAt")
        
        findAveEvaluatedData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                for object in objects {
                    self.timelineAveEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineAveEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelineAveEvaluatedData = array.mutableCopy() as NSMutableArray
                
                self.tableView.reloadData()
                self.view.hideLoading()
                
            }
                
            else{
                println("no data")
            }
        })
    }

    var timelineBadEvaluatedData:NSMutableArray! = NSMutableArray()
    
    func loadBadData(){
        timelineBadEvaluatedData.removeAllObjects()
        SoundPlayer.play("refresh.wav")
        var findBadEvaluatedData:PFQuery = PFQuery(className: "Comment")
        
        findBadEvaluatedData.whereKey("parent", equalTo: topic!)
        findBadEvaluatedData.whereKey("rating", equalTo: "lowRating")
        findBadEvaluatedData.orderByDescending("createdAt")
        
        findBadEvaluatedData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                for object in objects {
                    self.timelineBadEvaluatedData.addObject(object)
                }
                
                
                let array:NSArray = self.timelineBadEvaluatedData.reverseObjectEnumerator().allObjects
                self.timelineBadEvaluatedData = array.mutableCopy() as NSMutableArray
                
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
        return timelineEvaluatedData.count
        }
        
        else if segmentedRating.selectedSegmentIndex == 1{
            return timelineGoodEvaluatedData.count
        }
        
        else if segmentedRating.selectedSegmentIndex == 2{
            return timelineAveEvaluatedData.count
        }
        
        if segmentedRating.selectedSegmentIndex == 3{
            return timelineBadEvaluatedData.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:EvaluationTableViewCell = tableView.dequeueReusableCellWithIdentifier("evaluateCell", forIndexPath: indexPath) as EvaluationTableViewCell
        
        
        if segmentedRating.selectedSegmentIndex == 0 {
       
        let evaluatedData:PFObject = self.timelineEvaluatedData.objectAtIndex(indexPath.row) as PFObject
        cell.timeLabel.alpha = 0
        cell.studentMatric.alpha = 0
        cell.ratingDisplayed.alpha = 0
        
        var rating = evaluatedData.objectForKey("rating") as String?
        if rating == "lowRating" {
            
            cell.ratingDisplayed.setImage(UIImage(named:"ratingActive"), forState: UIControlState.Normal)
            
        }
            
            
        else if rating == "averageRating" {
            
            cell.ratingDisplayed.setImage(UIImage(named: "rating2"), forState: UIControlState.Normal)
            
        }
            
            
        else if rating == "goodRating" {
            
            cell.ratingDisplayed.setImage(UIImage(named: "rating3"), forState: UIControlState.Normal)
            
        }
            
        else {
            
            cell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
        }

        var findUsererData:PFQuery = PFUser.query()
        findUsererData.whereKey("objectId", equalTo: evaluatedData.objectForKey("userer").objectId)
        
        findUsererData.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]!,error:NSError!)->Void in
            
            if (error == nil) {
                
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.studentMatric.text = user.username
                
                //final animation
                spring(1.0){
                    cell.timeLabel.alpha = 1
                    cell.studentMatric.alpha = 1
                    cell.ratingDisplayed.alpha = 1
                }
            }
        })

        var dateFormat:NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "MMM dd, yyyy, HH:mm"
        cell.timeLabel.text = dateFormat.stringFromDate(evaluatedData.createdAt)
        }
        
        if segmentedRating.selectedSegmentIndex == 1 {
            
            let evaluatedGoodData:PFObject = self.timelineGoodEvaluatedData.objectAtIndex(indexPath.row) as PFObject
            cell.timeLabel.alpha = 0
            cell.studentMatric.alpha = 0
            cell.ratingDisplayed.alpha = 0
            
            var rating = evaluatedGoodData.objectForKey("rating") as String?
            if rating == "lowRating" {
                
                cell.ratingDisplayed.setImage(UIImage(named:"ratingActive"), forState: UIControlState.Normal)
                
            }
                
                
            else if rating == "averageRating" {
                
                cell.ratingDisplayed.setImage(UIImage(named: "rating2"), forState: UIControlState.Normal)
                
            }
                
                
            else if rating == "goodRating" {
                
                cell.ratingDisplayed.setImage(UIImage(named: "rating3"), forState: UIControlState.Normal)
                
            }
                
            else {
                
                cell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
            }
            
            var findUsererData:PFQuery = PFUser.query()
            findUsererData.whereKey("objectId", equalTo: evaluatedGoodData.objectForKey("userer").objectId)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]!,error:NSError!)->Void in
                
                if (error == nil) {
                    
                    let user:PFUser = (objects as NSArray).lastObject as PFUser
                    cell.studentMatric.text = user.username
                    
                    //final animation
                    spring(1.0){
                        cell.timeLabel.alpha = 1
                        cell.studentMatric.alpha = 1
                        cell.ratingDisplayed.alpha = 1
                    }
                }
            })
            
            var dateFormat:NSDateFormatter = NSDateFormatter()
            dateFormat.dateFormat = "MMM dd, yyyy, HH:mm"
            cell.timeLabel.text = dateFormat.stringFromDate(evaluatedGoodData.createdAt)
        }
        
        if segmentedRating.selectedSegmentIndex == 2 {
            
            let evaluatedAveData:PFObject = self.timelineAveEvaluatedData.objectAtIndex(indexPath.row) as PFObject
            cell.timeLabel.alpha = 0
            cell.studentMatric.alpha = 0
            cell.ratingDisplayed.alpha = 0
            
            var rating = evaluatedAveData.objectForKey("rating") as String?
            if rating == "lowRating" {
                
                cell.ratingDisplayed.setImage(UIImage(named:"ratingActive"), forState: UIControlState.Normal)
                
            }
                
                
            else if rating == "averageRating" {
                
                cell.ratingDisplayed.setImage(UIImage(named: "rating2"), forState: UIControlState.Normal)
                
            }
                
                
            else if rating == "goodRating" {
                
                cell.ratingDisplayed.setImage(UIImage(named: "rating3"), forState: UIControlState.Normal)
                
            }
                
            else {
                
                cell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
            }
            
            var findUsererData:PFQuery = PFUser.query()
            findUsererData.whereKey("objectId", equalTo: evaluatedAveData.objectForKey("userer").objectId)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]!,error:NSError!)->Void in
                
                if (error == nil) {
                    
                    let user:PFUser = (objects as NSArray).lastObject as PFUser
                    cell.studentMatric.text = user.username
                    
                    //final animation
                    spring(1.0){
                        cell.timeLabel.alpha = 1
                        cell.studentMatric.alpha = 1
                        cell.ratingDisplayed.alpha = 1
                    }
                }
            })
            
            var dateFormat:NSDateFormatter = NSDateFormatter()
            dateFormat.dateFormat = "MMM dd, yyyy, HH:mm"
            cell.timeLabel.text = dateFormat.stringFromDate(evaluatedAveData.createdAt)
        }
        
        if segmentedRating.selectedSegmentIndex == 3 {
            
            let evaluatedBadData:PFObject = self.timelineBadEvaluatedData.objectAtIndex(indexPath.row) as PFObject
            cell.timeLabel.alpha = 0
            cell.studentMatric.alpha = 0
            cell.ratingDisplayed.alpha = 0
            
            var rating = evaluatedBadData.objectForKey("rating") as String?
            if rating == "lowRating" {
                
                cell.ratingDisplayed.setImage(UIImage(named:"ratingActive"), forState: UIControlState.Normal)
                
            }
                
                
            else if rating == "averageRating" {
                
                cell.ratingDisplayed.setImage(UIImage(named: "rating2"), forState: UIControlState.Normal)
                
            }
                
                
            else if rating == "goodRating" {
                
                cell.ratingDisplayed.setImage(UIImage(named: "rating3"), forState: UIControlState.Normal)
                
            }
                
            else {
                
                cell.ratingDisplayed.setImage(UIImage(named: "rating"), forState: UIControlState.Normal)
            }
            
            var findUsererData:PFQuery = PFUser.query()
            findUsererData.whereKey("objectId", equalTo: evaluatedBadData.objectForKey("userer").objectId)
            
            findUsererData.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]!,error:NSError!)->Void in
                
                if (error == nil) {
                    
                    let user:PFUser = (objects as NSArray).lastObject as PFUser
                    cell.studentMatric.text = user.username
                    
                    //final animation
                    spring(1.0){
                        cell.timeLabel.alpha = 1
                        cell.studentMatric.alpha = 1
                        cell.ratingDisplayed.alpha = 1
                    }
                }
            })
            
            var dateFormat:NSDateFormatter = NSDateFormatter()
            dateFormat.dateFormat = "MMM dd, yyyy, HH:mm"
            cell.timeLabel.text = dateFormat.stringFromDate(evaluatedBadData.createdAt)
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
