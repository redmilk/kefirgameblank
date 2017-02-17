//
//  ViewController.swift
//  WikiTest
//
//  Created by Artem on 2/17/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class WikiViewController: UIViewController, WikipediaHelperDelegate {

    @IBOutlet weak var crossButton: UIButton!
    
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let wikiHelper = WikipediaHelper()
        wikiHelper.apiUrl = "http://en.wikipedia.org"
        wikiHelper.delegate = self
        
        let fighter = theGameController.previousFighter.name
        //zamenit probeli na nizhniy procherk
        let searchWord = fighter.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
                
        wikiHelper.fetchArticle(searchWord)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataLoaded(_ htmlPage: String!, withUrlMainImage urlMainImage: String!) {
        activityIndicator.stopAnimating()
        webView.loadHTMLString(htmlPage, baseURL: nil)
        activityIndicator.isHidden = true
    }

    
    @IBAction func crossPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

