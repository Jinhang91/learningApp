//
//  PDFViewController.swift
//  learningApp
//
//  Created by chinhang on 5/21/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit
import MessageUI

class PDFViewController: UIViewController,UIWebViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var visualBlur: UIVisualEffectView!
    @IBOutlet weak var progressView: UIProgressView!
    var hasFinishedLoading = false

    override func viewDidLoad() {
        navigationBarItems()
/*
        if let pdfLook = NSBundle.mainBundle().URLForResource("testfile", withExtension: "pdf", subdirectory: nil, localization: nil){
            if NSFileManager.defaultManager().fileExistsAtPath(pdfLook.path!) {
                println("file exists")
            let request = NSURLRequest(URL: pdfLook)
            webView.loadRequest(request)
            webView.delegate = self
            }
        }
  */
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentDirectory = paths[0] as String
        var pdfFileName = documentDirectory.stringByAppendingPathComponent("Evaluation.pdf")
        var url = NSURL(fileURLWithPath:pdfFileName)
        var urlString = url?.absoluteString
        let encodedString = urlString?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var webURL = NSURL(string: encodedString!)
        let request = NSURLRequest(URL: webURL!)
                webView.loadRequest(request)
                webView.delegate = self
        
    }
    
    func navigationBarItems(){
        var closeButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        closeButton.frame = CGRectMake(0,0,40,40)
        closeButton.addTarget(self, action: "closeButton:", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.tintColor = UIColorFromRGB(0xFFFFFF)
        closeButton.setImage(UIImage(named: "perfect"), forState: UIControlState.Normal)
        
        var leftBarButtonClose:UIBarButtonItem = UIBarButtonItem(customView: closeButton)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonClose, animated: true)
        
        var exportButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        exportButton.frame = CGRectMake(0,0,40,40)
        exportButton.addTarget(self, action: "shareButton:", forControlEvents: UIControlEvents.TouchUpInside)
        exportButton.tintColor = UIColorFromRGB(0xFFFFFF)
        exportButton.setImage(UIImage(named: "action-share"), forState: UIControlState.Normal)
        
        var rightBarButtonExport:UIBarButtonItem = UIBarButtonItem(customView: exportButton)
        self.navigationItem.setRightBarButtonItem(rightBarButtonExport, animated: true)
    }
    
    func closeButton(sender:UIButton!){
        
        navigationController?.popViewControllerAnimated(true)
        navigationController?.navigationBar.barTintColor = UIColorFromRGB(0x4FD7CE)
    }
    
    func shareButton(sender:UIButton!){
        if( MFMailComposeViewController.canSendMail() ) {
            println("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Evaluation PFD File")
            mailComposer.setMessageBody("This is what they sound like.", isHTML: false)
            
            if let filePath = NSBundle.mainBundle().pathForResource("testfile", ofType: "pdf") {
                println("File path loaded.")
                
                if let fileData = NSData(contentsOfFile: filePath) {
                    println("File data loaded.")
                    mailComposer.addAttachmentData(fileData, mimeType: "pdf", fileName: "testfile")
                }
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }

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
   
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        updateProgress()
        return true
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        hasFinishedLoading = false
        updateProgress()
        view.showLoading()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
       
        delay(1) { [weak self] in
            if let _self = self {
                _self.hasFinishedLoading = true
            }
        }
        view.hideLoading()
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        switch result.value{
        case MFMailComposeResultCancelled.value:
            println("Mail Canceled")
        case MFMailComposeResultFailed.value:
            println("Mail Failed")
        case MFMailComposeResultSaved.value:
            println("Mail Saved")
        case MFMailComposeResultSent.value:
            println("Mail Sent")
        default: break
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
