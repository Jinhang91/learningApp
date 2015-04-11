//
//  WebViewController.swift
//  learningApp
//
//  Created by chinhang on 4/10/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class WebViewController: UIViewController,UIWebViewDelegate {

    var hasFinishedLoading = false
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var urlString: String?
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(urlString)
     /*
        if let data = urlString {
        //let escapedString = data.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        let url = NSURL(string: data)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        
      
           webView.delegate = self
        }
     //webView.delegate = self
    */
    }
    

    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }

    override func viewWillAppear(animated: Bool) {
        if let data = urlString {
            //let escapedString = data.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            let url = NSURL(string: data)
            let request = NSURLRequest(URL: url!)
            webView.loadRequest(request)
        }
        
            webView.delegate = self
    }

    func webViewDidStartLoad(webView: UIWebView) {
        hasFinishedLoading = false
        updateProgress()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        delay(1) { [weak self] in
            if let _self = self {
                _self.hasFinishedLoading = true
            }
        }
    }
  

    deinit {
     //  webView.stopLoading()
      // webView.delegate = nil
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
    
}
