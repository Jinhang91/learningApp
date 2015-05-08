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
    
    @IBOutlet weak var visualBlur: UIVisualEffectView!
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
   //    navigationController?.navigationBar.barTintColor = UIColor(red: 236, green: 236, blue: 236, alpha: 0.1)
       navigationController?.navigationBar.translucent = true
       navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SanFranciscoDisplay-Regular", size: 18)!,  NSForegroundColorAttributeName: UIColorFromRGB(0x7B7B7B)]

    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        return false
    }



    
    func addLeftNavItemOnView()
    {
        
        backwardButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        backwardButton.frame = CGRectMake(-50, 0, 40, 40)
        backwardButton.tintColor = UIColorFromRGB(0x4FD7CE)
        backwardButton.setImage(UIImage(named:"perfect"), forState: UIControlState.Normal)
        backwardButton.setTitle("", forState: UIControlState.Normal)
        backwardButton.addTarget(self, action: "leftNavItemBack:", forControlEvents: UIControlEvents.TouchUpInside)
        var leftBarButtonItemBackward: UIBarButtonItem = UIBarButtonItem(customView: backwardButton)
        
        
        forwardButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        forwardButton.frame = CGRectMake(0, 0, 40, 40)
        forwardButton.tintColor = UIColorFromRGB(0x4FD7CE)
        forwardButton.setImage(UIImage(named:"perfectForward"), forState: UIControlState.Normal)
        forwardButton.addTarget(self, action: "leftNavItemForward:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var leftBarButtonItemForward: UIBarButtonItem = UIBarButtonItem(customView: forwardButton)
        
        self.navigationItem.setLeftBarButtonItems([leftBarButtonItemBackward, leftBarButtonItemForward],animated: true)
        
        
        var closeButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        closeButton.frame = CGRectMake(0,0,40,40)
        closeButton.addTarget(self, action: "closeButton:", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.tintColor = UIColorFromRGB(0x4FD7CE)
        //closeButton.titleLabel?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 20)
        closeButton.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
        
        var rightBarButtonClose:UIBarButtonItem = UIBarButtonItem(customView: closeButton)
       
     
        
        var refreshButton: UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        refreshButton.frame = CGRectMake(0,0,40,40)
        refreshButton.tintColor = UIColorFromRGB(0x4FD7CE)
        refreshButton.setImage(UIImage(named:"refresh"), forState: UIControlState.Normal)
        refreshButton.addTarget(self, action: "refreshButton:", forControlEvents: UIControlEvents.TouchUpInside)
    
        var rightBarButtonRefresh: UIBarButtonItem = UIBarButtonItem(customView: refreshButton)
        
        self.navigationItem.setRightBarButtonItems([rightBarButtonClose,rightBarButtonRefresh], animated: true)

    }

    func leftNavItemBack(sender:UIButton!){
        webView.goBack()
        println("goback")
    }
    
    func leftNavItemForward(sender:UIButton!){
        webView.goForward()
        println("goforward")
    }
    
    func refreshButton(sender:UIButton!){
        webView.reload()
        println("reload")
    }
    
    func closeButton(sender:UIButton!){
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        navigationController?.popViewControllerAnimated(true)
        navigationController?.navigationBar.barTintColor = UIColorFromRGB(0x4FD7CE)
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    

    /*
    func maskButtonDoesUse(){
        maskButton.hidden = false
        maskButton.alpha = 0
        spring(1){
            self.maskButton.alpha = 1
        }
    }
    
    func maskButtonDidUse(){
        maskButton.hidden = true
        maskButton.alpha = 1
        spring(1){
            self.maskButton.alpha = 0
        }
    }
    */
    func maskButtonDoesUse(){
        visualBlur.hidden = false
        visualBlur.alpha = 0
        spring(1){
            self.visualBlur.alpha = 1
        }
    }

    func maskButtonDidUse(){
        visualBlur.hidden = true
        visualBlur.alpha = 1
        spring(1){
            self.visualBlur.alpha = 0
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
        maskButtonDoesUse()
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
       shareTitle = webView.stringByEvaluatingJavaScriptFromString("document.title")
      //  navigationController?.navigationBar.topItem?.title = "\(shareTitle)"
        
        var headerWebView = UIView(frame: CGRectMake(0, 0, 100, 50))
        headerWebView.center = self.view.center
        view.addSubview(headerWebView)
        var linkTitle = UILabel(frame: CGRectMake(0, 5, 100, 22))
 
        linkTitle.text = shareTitle
        linkTitle.numberOfLines = 0
        linkTitle.font = UIFont(name: "SanFranciscoDisplay-Light", size: 16)
        linkTitle.textColor = UIColorFromRGB(0x000000)
        linkTitle.textAlignment = NSTextAlignment.Center
        headerWebView.addSubview(linkTitle)
     
        var linkurl = UILabel(frame: CGRectMake(0, 23, 100, 20))
        linkurl.text = "\(realURL)"
        linkurl.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 13)
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
           progressView.hidden = true
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
        webView?.stopLoading()
        webView?.delegate = nil
    }
}