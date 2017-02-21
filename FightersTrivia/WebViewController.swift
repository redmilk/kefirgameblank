//
//  WebViewController.swift
//  Guess the Fighter, Угадай Бойца
//
//  Created by Artem on 12/4/16.
//  Copyright © 2016 piqapp. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIScrollViewDelegate, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!    
    @IBOutlet weak var activityIndicator:
    UIActivityIndicatorView!
    var link: String!
    var currentTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for activity indicator
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    
        let fighter = theGameController.previousFighter.name
        //zamenit probeli na nizhniy procherk
        let searchWord: String
        if fighter.contains(" ") {
            searchWord = fighter.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
        } else {
            searchWord = fighter
        }
        print("SEARCHWORD::: " + searchWord)
        self.link = "https://en.wikipedia.org/wiki/\(searchWord)"
        let url = URL (string: link)
        let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
        
        // Do any additional setup after loading the view.
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 0 {
            let point = CGPoint(x: 0, y: scrollView.contentOffset.y)
            scrollView.contentOffset = point
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    @IBAction func forwardButton(_ sender: UIButton) {
        self.webView.goForward()
    }
    @IBAction func backButton(_ sender: UIButton) {
        self.webView.goBack()
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        self.webView.stopLoading()
    }
    
    @IBAction func refreshButton(_ sender: UIButton) {
        self.webView.reload()
    }
    
    @IBAction func crossPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
