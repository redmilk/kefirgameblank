//
//  GameOverViewController.swift
//  Guess the Fighter, Угадай Бойца
//
//  Created by Artem on 11/27/16.
//  Copyright © 2016 piqapp. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var gameOver: UILabel!
    
    var gradient: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///dlya togo chtobi gradient menyal orientaciyu pri izmenenii raskladki
        NotificationCenter.default.addObserver(self, selector: #selector(QuestionViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        highScoreLabel.text = theGameController.highscore.description
        scoreLabel.text = theGameController.score.description
        checkHighscoreOnGameOver()
        
        gradient = CAGradientLayer()
        gradient.colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
        //gradient.colors = [UIColor.blueColor().CGColor, UIColor.redColor().CGColor, UIColor.blueColor().CGColor]
        gradient.locations  = [0.0, 1.0]
        //gradient.locations = [0.0 , 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        gradient.zPosition = -10
        
        self.view.layer.addSublayer(gradient)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func retryButtonHandler(_ sender: UIButton) {
        theGameController.playSound("CLICK")
        theGameController.restartGame()
    }
    
    @IBAction func mainMenuButtonHandler(_ sender: UIButton) {
        theGameController.playSound("CLICK")
        performSegue(withIdentifier: "showMainMenu", sender: nil)
    }
    
    func checkHighscoreOnGameOver() {
        if theGameController.score >= theGameController.highscore {
            self.gameOver.text = "New Highscore!"
            theGameController.playSound("ACHIEVMENT")
            // animation
        } else {
            theGameController.playSound("GAMEOVER")
        }
    }
    
    ///dlya togo chtobi gradient menyal orientaciyu pri izmenenii raskladki
    func rotated()
    {
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        {
            //print("landscape")
            ifOrientChanged()
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            //print("Portrait")
            ifOrientChanged()
        }
        
    }
    
    fileprivate func ifOrientChanged() {
        gradient.frame = self.view.bounds
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
