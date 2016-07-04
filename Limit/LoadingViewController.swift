//
//  LoadingViewController.swift
//  Limit
//
//  Created by Rix Lai on 7/3/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    private let BACKGROUND_COLOR: UIColor = UIColor.init(red: 39.0/255.0, green: 179.0/255.0, blue: 160.0/255.0, alpha: 1)
    private let GIF_POSTFIX = "gif"
    private let GIF_NAME = "Loading"
    private let MIME_TYPE = "image/gif"
    
    // Light status bar content
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /* Load gif from local file */
    private func loadgif() {
        let filePath = NSBundle.mainBundle().pathForResource(GIF_NAME, ofType: GIF_POSTFIX)
        if(filePath != nil) {
            let data = NSData(contentsOfFile: filePath!)
            let url = NSURL.init(fileURLWithPath: filePath!)
            webView.loadData(data!, MIMEType: MIME_TYPE, textEncodingName: GIF_NAME+GIF_POSTFIX, baseURL: url)
            webView.userInteractionEnabled = false
        } else {
            // TODO: error handling
            print("Cannot load gif file")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = BACKGROUND_COLOR
        
        // Maybe a bug in simulator, a bit delay before gif moves, iPhone 6S Plus / 6 Plus
        // But it works on iPhone 5 and iPhone 6S
        dispatch_async(dispatch_get_main_queue()) {
            // Load gif
            self.loadgif()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
