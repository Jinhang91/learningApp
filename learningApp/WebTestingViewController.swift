//
//  WebTestingViewController.swift
//  learningApp
//
//  Created by chinhang on 4/18/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit
import WebKit

class WebTestingViewController: UIViewController, UIWebViewDelegate {

    var hasFinishedLoading = false
    var urlString:String?
    var myTimer:NSTimer!
    @IBOutlet weak var backwardButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    @IBOutlet weak var webTitle: UILabel!
    @IBOutlet weak var webURL: UILabel!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var webview: WKWebView!
    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backwardButtonDidTouch(sender: AnyObject) {
        webView.goBack()
    }

    @IBAction func forwardButtonDidTouch(sender: AnyObject) {
        webView.goForward()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backwardButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
        webView.delegate = self
    }
    func webViewDidStartLoad(webView: UIWebView) {
        hasFinishedLoading = false
        progressView.progress = 0.0
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
    
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
       /* delay(1) { [weak self] in
            if let _self = self {
                _self.hasFinishedLoading = true
            }
        }*/
        hasFinishedLoading = true
    }
    
    
    deinit {
        // webView.stopLoading()
        // webView.delegate = nil
    }
    
    func updateProgress() {
    /*    if progressView.progress >= 1 {
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
    */
        if hasFinishedLoading {
            if progressView.progress >= 1 {
                progressView.hidden = true
                self.myTimer.invalidate()
            } else {
                progressView.progress += 0.1
            }
        } else {
            progressView.progress += 0.05
            if progressView.progress >= 0.95 {
                progressView.progress = 0.95
            }
        }
}

}
