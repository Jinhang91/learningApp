//
//  WebViewController.swift
//  learningApp
//
//  Created by chinhang on 4/10/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController,UIWebViewDelegate {

    var hasFinishedLoading = false

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var shareTitle: String!
    var urlString: String?
    var realURL:NSURL!
    var backwardButton:UIButton!
    var forwardButton:UIButton!
    
    @IBOutlet weak var maskButton: UIButton!
    
    override func viewDidLoad() {
      super.viewDidLoad()
        println(urlString)
        println(realURL)
        maskButton.hidden = true
        addLeftNavItemOnView()
        if let data = urlString {
            //let escapedString = data.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            realURL = NSURL(string: data)
            let request = NSURLRequest(URL: realURL!)
            webView.loadRequest(request)
        
        
        webView.delegate = self
        }

    }
    
    override func viewDidAppear(animated: Bool) {

        navigationController?.navigationBar.topItem?.title = "Loading..."
        
       navigationController?.navigationBar.barTintColor = UIColorFromRGB(0xECECEC)
       navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!,  NSForegroundColorAttributeName: UIColorFromRGB(0x7B7B7B)]

    }
    

    
    func addLeftNavItemOnView()
    {
        
        backwardButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        backwardButton.frame = CGRectMake(-50, 0, 40, 40)
        backwardButton.tintColor = UIColorFromRGB(0x4FD7CE)
        backwardButton.setImage(UIImage(named:"perfect"), forState: UIControlState.Normal)
        backwardButton.setTitle(" ", forState: UIControlState.Normal)
        backwardButton.addTarget(self, action: "leftNavItemBack:", forControlEvents: UIControlEvents.TouchUpInside)
        var leftBarButtonItemBackward: UIBarButtonItem = UIBarButtonItem(customView: backwardButton)
        
        
        forwardButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        forwardButton.frame = CGRectMake(0, 0, 40, 40)
        forwardButton.tintColor = UIColorFromRGB(0x4FD7CE)
        forwardButton.setImage(UIImage(named:"perfectForward"), forState: UIControlState.Normal)
        forwardButton.addTarget(self, action: "leftNavItemForward:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var leftBarButtonItemForward: UIBarButtonItem = UIBarButtonItem(customView: forwardButton)
        
        self.navigationItem.setLeftBarButtonItems([leftBarButtonItemBackward, leftBarButtonItemForward],animated: true)
        
        
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        myBackButton.addTarget(self, action: "closeButton:", forControlEvents: UIControlEvents.TouchUpInside)
        //myBackButton.setTitle("  Back", forState: UIControlState.Normal)
        myBackButton.tintColor = UIColorFromRGB(0x4FD7CE)
        myBackButton.titleLabel?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 20)
        myBackButton.setImage(UIImage(named: "icon-close"), forState: UIControlState.Normal)
        
        myBackButton.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.rightBarButtonItem  = myCustomBackButtonItem
     
        /*
        let buttonClose: UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        buttonClose.frame = CGRectMake(0,0,40,40)
        buttonClose.setImage(UIImage(named:"action-share"), forState: UIControlState.Normal)
        buttonClose.addTarget(self, action: "closeButton:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonClose.sizeToFit()
        var rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonClose)
        
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: true)
*/
    }

    func leftNavItemBack(sender:UIButton!){
        webView.goBack()
        println("goback")
    }
    
    func leftNavItemForward(sender:UIButton!){
        webView.goForward()
        println("goforward")
    }
    
    func closeButton(sender:UIButton!){
        // dismissViewControllerAnimated(true, completion: nil)
        //UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        navigationController?.popViewControllerAnimated(true)
        navigationController?.navigationBar.barTintColor = UIColorFromRGB(0x4FD7CE)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    

    func maskButtonDidUse(){
        maskButton.hidden = true
        maskButton.alpha = 1
        spring(1){
            self.maskButton.alpha = 0
        }
    }


    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        updateProgress()
        return true
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        hasFinishedLoading = false
        updateProgress()
        view.showLoading()
        maskButton.hidden = false
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
       shareTitle = webView.stringByEvaluatingJavaScriptFromString("document.title")
      //  navigationController?.navigationBar.topItem?.title = "\(shareTitle)"
        
        var headerWebView = UIView(frame: CGRectMake(0, 0, 190, 50))
        var linkTitle = UILabel(frame: CGRectMake(0, 5, 190, 22))
 
        linkTitle.text = shareTitle
        linkTitle.numberOfLines = 2
        linkTitle.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 18)
        linkTitle.textColor = UIColorFromRGB(0x7B7B7B)
        linkTitle.textAlignment = NSTextAlignment.Center
        headerWebView.addSubview(linkTitle)
     
        var linkurl = UILabel(frame: CGRectMake(0, 22, 190, 20))
        linkurl.text = "\(realURL)"
        linkurl.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 14)
        linkurl.textColor = UIColorFromRGB(0x7B7B7B)
        linkurl.textAlignment = NSTextAlignment.Center
        headerWebView.addSubview(linkurl)
        
        navigationItem.titleView = headerWebView
        
        delay(1) { [weak self] in
            if let _self = self {
                _self.hasFinishedLoading = true
            }
        }
       
        backwardButton.enabled = webView.canGoBack
        forwardButton.enabled  = webView.canGoForward

        view.hideLoading()
        maskButtonDidUse()
    }
  

    func updateProgress() {
        if progressView.progress >= 1 {
           progressView.hidden = false
        } else {
            
            if hasFinishedLoading {
                progressView.progress += 0.002
            } else {
                if progressView.progress <= 0.3 {
                    progressView.progress += 0.004
                } else if progressView.progress <= 0.6 {
                    progressView.progress += 0.002
                } else if progressView.progress <= 0.9 {
                    progressView.progress += 0.001
                } else if progressView.progress <= 0.94 {
                    progressView.progress += 0.0001
                } else {
                    progressView.progress = 0.9401
                }
            }
            
            delay(0.008) { [weak self] in
                if let _self = self {
                    _self.updateProgress()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        if webView.loading {
            webView.stopLoading()
        }
        
        let alert = UIAlertController(title: "Stopped Loading", message: "This site is memory intensive and may cause a crash. Please use a browser instead.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
            style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        }))
        
        alert.addAction(UIAlertAction(title: "Open in Safari",
            style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(self.realURL)
                return
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    deinit {
      //  webView.stopLoading()
      //  webView.delegate = nil
    }
}