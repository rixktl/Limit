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
    fileprivate let BACKGROUND_COLOR: UIColor = UIColor.init(red: 39.0/255.0,
                                                             green: 179.0/255.0,
                                                             blue: 160.0/255.0,
                                                             alpha: 1)
    fileprivate let GIF_POSTFIX = "gif"
    fileprivate let GIF_NAME = "Loading"
    fileprivate let MIME_TYPE = "image/gif"
    
    // Light status bar content
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    /* Load gif from local file */
    fileprivate func loadgif() {
        let filePath = Bundle.main.path(forResource: GIF_NAME,
                                        ofType: GIF_POSTFIX)
        if(filePath != nil) {
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
            let url = URL.init(fileURLWithPath: filePath!)
            webView.load(data!, mimeType: MIME_TYPE,
                         textEncodingName: GIF_NAME+GIF_POSTFIX, baseURL: url)
            //webView.loadRequest(URLRequest.init(url: url))
            // this makes no difference on loading performance in simulator
         
        } else {
            // TODO: error handling
            print("Cannot load gif file")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.backgroundColor = BACKGROUND_COLOR
        
        // Maybe a bug in simulator, there is a delay before gif moves,
        // iPhone 6S Plus, 6 Plus, 7 Plus affected
        // But it works on iPhone 5 and iPhone 6S and iPhone 7
        DispatchQueue.main.async {
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
