//
//  SplashScreenViewController.swift
//  Guess the Fighter, Угадай Бойца
//
//  Created by Artem on 12/9/16.
//  Copyright © 2016 piqapp. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        /////GAMECONTROLLER/////
        theGameController = GameController()
        theGameController.soundMute = false
        let splashScreenTime = 3
        // cherez 3 sekundi otrkivaem start screen
        let triggerTime = (Int64(NSEC_PER_SEC) * Int64(splashScreenTime))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.performSegue(withIdentifier: "showStartScreen", sender: nil)
        })
    }
}
