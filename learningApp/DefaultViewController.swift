//
//  ViewController.swift
//  learningApp
//
//  Created by chinhang on 3/8/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        /* PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
        testObject[@"foo"] = @"bar";
        [testObject saveInBackground];
*/
        var testObject:PFObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.save()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

