//
//  StartGameViewController.swift
//  Guess the Fighter, Угадай Бойца
//
//  Created by Artem on 11/29/16.
//  Copyright © 2016 piqapp. All rights reserved.
//

import UIKit

class StartGameViewController: UIViewController {

    var gradient: CAGradientLayer!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var titleStack: UIStackView!
    @IBOutlet weak var topStripMenuStack: UIStackView!
    @IBOutlet weak var lowerStripMenuStack: UIStackView!
    
    @IBOutlet weak var moreGamesButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var transparentLabel: UILabel!
    @IBOutlet weak var enButton: UIButton!
    @IBOutlet weak var ruButton: UIButton!
    
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    @IBOutlet weak var fightersTriviaTitleLabel: UILabel!
    fileprivate var soundMute: Bool = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///uzhe ne transparent, teper tam highscore
        theGameController.soundMute = self.soundMute

        self.transparentLabel.text = "\(theGameController.highscore)"
        
        ///dlya togo chtobi gradient menyal orientaciyu pri izmenenii raskladki
        NotificationCenter.default.addObserver(self, selector: #selector(QuestionViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        gradient = CAGradientLayer()
        gradient.colors = [UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.blue.cgColor]
        gradient.locations = [0.0 , 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.6)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        gradient.zPosition = -10
        
        self.view.layer.addSublayer(gradient)
        // Do any additional setup after loading the view.
    }
                    ///
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "startGame" {
            let dest = segue.destinationViewController as! QuestionViewController
            dest.soundMute = self.soundMute
        }
    }*/

    
    
    func gradientColorChangeAnimation() {
        let gradientAnimationColors = CABasicAnimation(keyPath: "colors")
        gradientAnimationColors.fromValue = [UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.blue.cgColor]
        gradientAnimationColors.toValue = [UIColor.white.cgColor, UIColor.red.cgColor, UIColor.black.cgColor]
        gradientAnimationColors.duration = 10.0
        gradientAnimationColors.autoreverses = true
        gradientAnimationColors.repeatCount = Float.infinity
        gradient.add(gradientAnimationColors, forKey: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        gradientColorChangeAnimation()
        initialButtonAnimation()
        // test
        //transparentLabel.numberOfLines = 1
        transparentLabel.minimumScaleFactor = 0.5
        transparentLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startGameButtonHandler(_ sender: UIButton) {
        theGameController.playSound("CLICK")
    }
    
    ///dlya togo chtobi gradient menyal orientaciyu pri izmenenii raskladki
    func rotated() {
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) {
            //print("landscape")
            ifOrientChanged()
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)) {
            //print("Portrait")
            ifOrientChanged()
        }
    }
    
    fileprivate func ifOrientChanged() {
        gradient.frame = self.view.bounds
    }

    @IBAction func moreGamesButtonHandler(_ sender: UIButton) {
        initialButtonAnimation()
    }
    
    @IBAction func muteButtonHandler(_ sender: UIButton) {
        theGameController.playSound("CLICK")
        self.soundMute = !self.soundMute
        self.muteButton.backgroundColor = (self.soundMute == false) ? UIColor.black : UIColor.red
        self.muteButtonAnimation(self.soundMute)
    }
    
    func muteButtonAnimation(_ toRoundShape: Bool) {
        
        let anim = CABasicAnimation(keyPath: "cornerRadius")
        
        
        UIView.animate(withDuration: 0.5, animations: {
            self.muteButton.layer.cornerRadius = toRoundShape ? 0.25 : 1.0
            }, completion: nil)
    }
    
    @IBAction func shareSheet(_ sender: AnyObject) {
        
        let firstActivityItem = "Do you track fighting sports?  Come and try your knowledge in the FightersTrivia!  MMA, BOXING, K-1.  More than 200 fighters, free to play."
        ///let secondActivityItem : NSURL = NSURL(string: "https://en.wikipedia.org/wiki/Floyd_Mayweather_Jr.")!
        // If you want to put an image
        let image : UIImage = UIImage(named: "conor1")!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem/*, secondActivityItem*/, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func initialButtonAnimation() {
        
        let anim = CASpringAnimation(keyPath: "position.y")
        anim.beginTime = CACurrentMediaTime() + 0
        anim.damping = 9.1
        anim.initialVelocity = 0.0
        anim.stiffness = 300.0
        anim.mass = 2.0
        anim.duration = anim.settlingDuration
        anim.fromValue = self.playButton.layer.position.y - 200
        anim.toValue = self.playButton.layer.position.y
        self.playButton.layer.add(anim, forKey: nil)
        
        let anim1 = CASpringAnimation(keyPath: "position.y")
        anim1.beginTime = CACurrentMediaTime() + 0.1
        anim1.damping = 7.1
        anim1.initialVelocity = 0.0
        anim1.stiffness = 300.0
        anim1.mass = 1.5
        anim1.duration = anim.settlingDuration
        anim1.fromValue = self.rateButton.layer.position.y + 200
        anim1.toValue = self.rateButton.layer.position.y
        self.rateButton.layer.add(anim1, forKey: nil)
        
        let anim2 = CASpringAnimation(keyPath: "position.y")
        anim2.beginTime = CACurrentMediaTime() + 0.2
        anim2.damping = 7.1
        anim2.initialVelocity = 0.0
        anim2.stiffness = 150.0
        anim2.mass = 1.0
        anim2.duration = anim.settlingDuration
        anim2.fromValue = self.shareButton.layer.position.y + 200
        anim2.toValue = self.shareButton.layer.position.y
        self.shareButton.layer.add(anim2, forKey: nil)

        let anim3 = CASpringAnimation(keyPath: "position.y")
        anim3.beginTime = CACurrentMediaTime() + 0.3
        anim3.damping = 7.1
        anim3.initialVelocity = 0.0
        anim3.stiffness = 150.0
        anim3.mass = 1.0
        anim3.duration = anim.settlingDuration
        anim3.fromValue = self.aboutButton.layer.position.y + 200
        anim3.toValue = self.aboutButton.layer.position.y
        self.aboutButton.layer.add(anim3, forKey: nil)
        
        let anim4 = CASpringAnimation(keyPath: "position.y")
        anim4.beginTime = CACurrentMediaTime()
        anim4.damping = 7.1
        anim4.initialVelocity = 0.0
        anim4.stiffness = 150.0
        anim4.mass = 1.0
        anim4.duration = anim.settlingDuration
        anim4.fromValue = self.moreGamesButton.layer.position.y + 200
        anim4.toValue = self.moreGamesButton.layer.position.y
        self.moreGamesButton.layer.add(anim4, forKey: nil)
        
        let anim5 = CASpringAnimation(keyPath: "position.y")
        anim5.beginTime = CACurrentMediaTime() + 0.1
        anim5.damping = 7.1
        anim5.initialVelocity = 0.0
        anim5.stiffness = 150.0
        anim5.mass = 1.0
        anim5.duration = anim.settlingDuration
        anim5.fromValue = self.transparentLabel.layer.position.y + 200
        anim5.toValue = self.transparentLabel.layer.position.y
        self.transparentLabel.layer.add(anim5, forKey: nil)
        
        let anim6 = CASpringAnimation(keyPath: "position.y")
        anim6.beginTime = CACurrentMediaTime() + 0.2
        anim6.damping = 7.1
        anim6.initialVelocity = 0.0
        anim6.stiffness = 150.0
        anim6.mass = 1.0
        anim6.duration = anim.settlingDuration
        anim6.fromValue = self.muteButton.layer.position.y + 200
        anim6.toValue = self.muteButton.layer.position.y
        self.muteButton.layer.add(anim6, forKey: nil)
        

        let anim7 = CASpringAnimation(keyPath: "position.y")
        anim7.beginTime = CACurrentMediaTime() + 0.3
        anim7.damping = 7.1
        anim7.initialVelocity = 0.0
        anim7.stiffness = 150.0
        anim7.mass = 1.0
        anim7.duration = anim.settlingDuration
        anim7.fromValue = self.enButton.layer.position.y + 200
        anim7.toValue = self.enButton.layer.position.y
        self.enButton.layer.add(anim7, forKey: nil)

        let anim8 = CASpringAnimation(keyPath: "position.y")
        anim8.beginTime = CACurrentMediaTime() + 0.4
        anim8.damping = 7.1
        anim8.initialVelocity = 0.0
        anim8.stiffness = 150.0
        anim8.mass = 1.0
        anim8.duration = anim.settlingDuration
        anim8.fromValue = self.ruButton.layer.position.y + 200
        anim8.toValue = self.ruButton.layer.position.y
        self.ruButton.layer.add(anim8, forKey: nil)
        
        let anim9 = CASpringAnimation(keyPath: "transform.scale")
        anim9.damping = 7.1
        anim9.initialVelocity = 0.0
        anim9.stiffness = 150.0
        anim9.mass = 1.0
        anim9.duration = anim.settlingDuration
        anim9.fromValue = 0.1
        anim9.toValue = 1.0
        self.fightersTriviaTitleLabel.layer.add(anim9, forKey: nil)


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
