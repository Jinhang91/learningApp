//
//  TestingViewController.swift
//  learningApp
//
//  Created by chinhang on 4/11/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController, UITextViewDelegate{

    @IBOutlet weak var textingView: UITextView!
    let transitionManager = TransitionManager()
    var urlTest:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        textingView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(textView: UITextView!, shouldInteractWithURL URL: NSURL!, inRange characterRange: NSRange) -> Bool {
        println("Link Selected!")
        println(URL)
        println(URL.absoluteString)
      
        urlTest = URL.absoluteString
       
        performSegueWithIdentifier("testSegue", sender: self)
        
        return false
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "testSegue"{
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
    
}