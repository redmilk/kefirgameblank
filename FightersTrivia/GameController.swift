//
//  GameController.swift
//  Guess the Fighter, Угадай Бойца
//
//  Created by Artem on 11/14/16.
//  Copyright © 2016 piqapp. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AudioToolbox

//var highScore: Int!

var theGameController: GameController!

class GameController {
    fileprivate var fighters: [Fighter] = [Fighter]()
    fileprivate var chicks: [Fighter] = [Fighter]()

    
    var currentFighter: Fighter!
    var triesLeft: Int = 3
    var answerListCount: Int!
    var currentAnswerListData: [String]!
    var currentRightAnswerIndex: Int!
    var score: Int = 0
    var highscore: Int
    var viewFighterNameLabel: UILabel?
    var scoreLabel: UILabel?
    var soundMute: Bool?
    var gameIsOver: Bool = false
    var isItFirstQuestion: Bool = true
    var skipFighter: Bool = false
    var fightersCount: Int!
    var betweenQuestionView: UIView!
    var previousFighter: Fighter!
    var isBetweenQuestionsViewOpen: Bool = false
    
    init() {
        
        CURRENTQUESTIONINDEX = 0    ///
        
        self.fighters = [Fighter(name: "Jennyfer Lawrence", image: "lawrence"),
                         Fighter(name: "Maria Kachurovska", image: "masha"),
                         Fighter(name: "Kira Knightley", image: "knightley"),
                         Fighter(name: "Jennyfer Connelly", image: "conneli"),
                         Fighter(name: "Ariel Cabbel", image: "cabbel"),
                         Fighter(name: "Elisha Cuthbert", image: "sosedka"),
                         Fighter(name: "Liv Tyler", image: "tyler"),
                         Fighter(name: "Fergie Duhamel", image: "fergie"),
                         Fighter(name: "Britney Spears", image: "spears"),
                         Fighter(name: "Iggy Azelia", image: "azelia"),
                         Fighter(name: "Nicky Minaj", image: "minaj"),]
        
        
        self.chicks = [Fighter(name: "Manny Paquiao", image: "pac1"),
                         Fighter(name: "Mike Tyson", image: "tyson1"),
                         Fighter(name: "John Johns", image: "jones1"),
                         Fighter(name: "Conor McGregor", image: "conor1"),
                         Fighter(name: "Alexandr Emelianenko", image: "aemelianenko1"),
                         Fighter(name: "Buakaw Banchamek", image: "buakaw1"),
                         Fighter(name: "Fedor Emelianenko", image: "fedor1"),
                         Fighter(name: "Batu Hasikov", image: "hasikov1"),
                         Fighter(name: "Evander Hollyfield", image: "hollyfield1"),
                         Fighter(name: "Artur Kyshenko", image: "kyshenko1"),
                         Fighter(name: "Denis Lebedev", image: "lebedev1"),
                         Fighter(name: "Vasiliy Lomachenko", image: "lomachenko1"),
                         Fighter(name: "Floyd Mayweather", image: "mayweather1"),
                         Fighter(name: "Aleksandr Povetkin", image: "povetkin1"),
                         Fighter(name: "Andy Souwer", image: "souwer1"),
                         Fighter(name: "Vladimir Klichko", image: "vklichko1"),
                         Fighter(name: "Mike Zambidis", image: "zambidis1"),  ]
        self.fightersCount = self.fighters.count
        
        ///esli ukazano bolshe chem nuzhno to beskonechniy cikl
        self.answerListCount = 5 //
        
        //highscore
        if let hs = UserDefaults.standard.value(forKey: "highscore") as? Int {
            self.highscore = hs
        } else {
            self.highscore = 0
        }
    }
    ///VSE ZAVYAZANO NA INDEKSE, KOGDA EGO MENYAEM ON UPRAVLYAET IZMENENIEM OSTALNOGO
    ///kogda menyaem indeks tekushego voprosa, menyaetsya currentFighter na sootv.
    var CURRENTQUESTIONINDEX: Int {
        
        didSet {
            ///proverka - perviy li eto vopros po poryadku
            if self.isItFirstQuestion == true {
                self.isItFirstQuestion = false
                return
            }
            //sohranim predisushego boica chtob zagruzit aktualnogo v wikiview
            qVController.refreshCurrentFighterNameLabel(self.fighters[CURRENTQUESTIONINDEX].name)
            /// chtob dva raza podryad ne srabativala animaciya smeni kartinki pri restarte
            /// esli restart, to obnulyaem svoistva igri i ostalnnoe propuskaem
            if self.gameIsOver == true {
                self.initStartUpGameValues()
                return
            }
            
            /// esli voprosi zakonchilis
            if CURRENTQUESTIONINDEX > self.fighters.count {
                return
            }
            //*****
            self.previousFighter = currentFighter
            self.initCurrentQuestion()
            /// esli eto ne "propustit boica"
            if (self.skipFighter == false) {
                self.playerWasRightGoToTheNextQuestion()
                
                /// to propustit vopros, igrok oshibsya
            } else if (self.skipFighter == true) {
                self.playerWasWrongSkipThisQuestion()
                self.skipFighter = false
            }
        }
    }
    
    func startGame() {
        ///zapustit igru
        self.initGame()
        
    }
    
    func initCurrentQuestion() {
        self.currentFighter = self.fighters[CURRENTQUESTIONINDEX]
        self.currentAnswerListData = self.getRandomAnswers(howmany: answerListCount)
        self.currentRightAnswerIndex = generateRightAnswer()
        // PAUZA MEZHDU VOPROSAMI, ZADERZHKA DO OBNOVLENIYA PICKERA
        let triggerTime = (Int64(NSEC_PER_SEC) * Int64(1))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            qVController.reloadPickerView()
            qVController.pickerSelectMiddleOption()
        })
    }
    
    func initStartUpGameValues() {
        self.triesLeft = 3
        self.score = 0
        self.gameIsOver = false
        self.isItFirstQuestion = true
        self.fighters.shuffle()
        self.scoreLabel!.text = score.description
        qVController.resetDots()
        // userDefault
        self.highscore = UserDefaults.standard.value(forKey: "highscore") as! Int
    }
    
    /// igrok oshibsya, propustit tekushiy vopros s nebolshoi zaderzhkoi
    func playerWasWrongSkipThisQuestion() {
        // PAUZA MEZHDU VOPROSAMI, KOGDA IGROK OSHIBSYA
        let triggerTime = (Int64(NSEC_PER_SEC) * Int64(1))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            qVController.setNewImage(self.fighters[self.CURRENTQUESTIONINDEX].image)
            /// stavit centralnuyu v pickere opciyu vibora na sledushiy vopros
            qVController.isBetweenQuestions = false
        })
    }
    
    /// igrok otvetil verno, pokazat animaciyu mezhdu voprosami, pereiti k sleduyushemu voprosu
    func playerWasRightGoToTheNextQuestion() {
        self.score += 1 /// SCORE
        self.scoreLabel!.text = self.score.description
        qVController.congratStripSetState("OPEN")
        qVController.answerButtonSetState("CLOSE")
        /*
         *   PLACE FOR BLUR EFFECT ADDING
         */
        
        // zamenit na animation delay
        let triggerTime = (Int64(NSEC_PER_SEC) * Int64(1.0))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            // MARK: - between question view
            //refresh frame of the betweenQuestionView
            self.isBetweenQuestionsViewOpen = true
            self.betweenQuestionView.frame = qVController.picker.frame
            qVController.moreInfoButton.becomeFirstResponder()
            //self.betweenQuestionView.constraints = qVController.picker.constraints
            UIView.transition(with: self.betweenQuestionView, duration: 0.55, options: [.curveEaseOut, .transitionCurlDown], animations: {
                self.betweenQuestionView.isHidden = false
            }, completion: nil)
        })
        
        
        // PAUZA MEZHDU VOPROSAMI, KOGDA IGROK OTVETIL VERNO!
        let triggerTime_ = (Int64(NSEC_PER_SEC) * Int64(3))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime_) / Double(NSEC_PER_SEC), execute: { () -> Void in
            qVController.refreshCurrentFighterNameLabel("? ? ? ? ?")
            qVController.pickerSelectMiddleOption()
            qVController.congratStripSetState("CLOSE")
            qVController.answerButtonSetState("OPEN")
            qVController.setNewImage(self.fighters[self.CURRENTQUESTIONINDEX].image)
            /// stavit centralnuyu v pickere opciyu vibora na sledushiy vopros
            qVController.isBetweenQuestions = false
            /*
             *   PLACE FOR BLUR EFFECT REMOVING, TRANSITION
             */
            UIView.transition(with: self.betweenQuestionView, duration: 0.55, options: [.curveEaseOut, .transitionFlipFromTop], animations: {
                self.betweenQuestionView.isHidden = true
            }, completion: nil)
            // with no animation
            //self.betweenQuestionView.isHidden = true
        })
    }
    
    //////////////////////////////// RIGHT OR WRONG /////////////////////////////////
    
    func checkRightOrWrong(answer: String) -> Bool {
        let result = self.currentFighter.name == answer
        if result == false {  ///  PLAYER WAS WRONG
            qVController.animateImageViewIfPlayerWrong()
            self.playerDidMistake()
        } else {              ///  PLAYER WAS RIGHT
            self.playerDidRightAnswer()
            
        }
        return result
    }
    
    /// RIGHT
    func playerDidRightAnswer() {
        playSound("RIGHT")
        // blur picker func
        qVController.imageViewFlyDownAnimation()
        qVController.answerButtonAnimationIfRightForGradients()
        if gameIsOver == false {
            goToTheNextQuestion()
        }
    }
    
    /// MISTAKE
    func playerDidMistake() {
        qVController.backGroundColorChangeAnimationOnAnswer("WRONG")
        qVController.answerButtonAnimationIfWrongForGradients()
        playSound("WRONG")
        if self.triesLeft - 1 >= 0 {
            self.triesLeft -= 1
            qVController.changeXtoDot()
            self.skipFighter = true
            if(CURRENTQUESTIONINDEX >= self.fighters.count - 1) {
                return
            }
            self.CURRENTQUESTIONINDEX += 1
        }
        //self.checkForPlayerGameOver(delayToGameOverAnimation: 1.0)
    }
    
    /// CHECK IF GAME OVER
    func checkForPlayerGameOver(delayToGameOverAnimation: CFTimeInterval) {
        if self.triesLeft <= 0 {
            // DELAY
            let triggerTime = (Int64(NSEC_PER_SEC) * Int64(delayToGameOverAnimation))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                ///zapomnit polozhenie gradienta i zapustit ego animaciyu s togozhe momenta posle restarta
                self.checkIfHighScore(self.score)
                self.gameIsOver = true
                qVController.congratStripConstraintsSetToClose()
                qVController.doSegueWithIdentifier("showGameOver")
            })
            
        }
    }
    
    ///////////////// NEXT QUESTION //////////////// NEXT QUESTION////////////// GAME DONE
    func goToTheNextQuestion() {
        let ifWeCanGoToTheNextQuestion = CURRENTQUESTIONINDEX + 1
        if ifWeCanGoToTheNextQuestion > fighters.count-1 {
            ///FIX
            wholeGameIsPathedBy()
        } else { //continue playing
            CURRENTQUESTIONINDEX += 1
        }
    }
    
    ////////////////// MY SHUFFLE FUNC ///////////////////////
    ///poluchit massiv sluchainih otvetov
    func getRandomAnswers(howmany: Int) -> [String] {
        var result = [String]()
        var randomFighterForAnswersList: Fighter!
        for _ in 1...howmany {
            let rand = Int(arc4random_uniform(UInt32(fighters.count)))
            randomFighterForAnswersList = self.fighters[rand]
            
            ///esli imya sluchainogo sovpadaet s nashim tekushim v igre ili takoi uzhe dobavlen v spisok otvetov
            while randomFighterForAnswersList.name == self.currentFighter.name || result.contains(where: { $0 == randomFighterForAnswersList.name }) {
                let rand = arc4random_uniform(UInt32(fighters.count))
                randomFighterForAnswersList = self.fighters[Int(rand)]
            }
            result.append(randomFighterForAnswersList.name)
        }
        self.currentAnswerListData = result
        return result
    }
    
    ///generirovat indeks pravilnogo otveta
    func generateRightAnswer() -> Int {
        
        ///OTKLYUCHAEM PERVIY I POSLEDNIY VARIANTI K VIBORU
        
        var rand = 0
        repeat {
            rand = Int(arc4random_uniform(UInt32(self.answerListCount)))
        } while (rand == answerListCount - 1 || rand == 0)
        
        self.currentAnswerListData[rand] = self.currentFighter.name
        self.currentRightAnswerIndex = rand
        return rand
    }
    
    
    
    ///     GAME DONE
    func wholeGameIsPathedBy() {
        self.gameIsOver = true
        playSound("GAMEDONE")
        qVController.doSegueWithIdentifier("showGameDone")
    }
    
    func playSound(_ soundName: String) {
        if self.soundMute == true {
            return
        }
        switch soundName {
        case "RIGHT":
            AudioServicesPlaySystemSound(1440)//1394)
            break
        case "WRONG":
            AudioServicesPlaySystemSound(1053)
            break
        case "GAMEOVER":
            AudioServicesPlaySystemSound(1006)
            break
        case "ACHIEVMENT":
            AudioServicesPlaySystemSound(1383)
            break
        case "SCROLL":
            AudioServicesPlaySystemSound(1121) //1222
            break
        case "GAMEDONE":
            AudioServicesPlaySystemSound(1332)
            break
        case "CHANGEIMAGE":
            AudioServicesPlaySystemSound(1129)
            break
        case "CLICK":
            AudioServicesPlaySystemSound(1130)
        default:
            break
        }
    }
    
    func restartGame() {
        CURRENTQUESTIONINDEX = 0
        self.initGame()
    }
    
    func checkIfHighScore(_ yourScore: Int) -> Bool {
        var r: Bool = false
        if yourScore > self.highscore {
            print("NEW HIGHSCORE")
            self.highscore = yourScore
            UserDefaults.standard.set(self.highscore, forKey: "highscore")
            r = true
        }
        if yourScore == self.highscore {
            /// Uteshit igroka potomu chto emu ne hvatilo vsego 1 ochka do highscore :)
        }
        return r
    }
    
    func initGame() {
        self.triesLeft = 3
        self.score = 0
        self.gameIsOver = false
        self.isItFirstQuestion = true
        self.fighters.shuffle()
        self.currentFighter = self.fighters[CURRENTQUESTIONINDEX]
        self.previousFighter = currentFighter
        self.scoreLabel!.text = score.description
        self.currentAnswerListData = self.getRandomAnswers(howmany: answerListCount)
        self.currentRightAnswerIndex = generateRightAnswer()
        qVController.resetDots()
        qVController.reloadPickerView()
        qVController.refreshCurrentFighterNameLabel("? ? ? ? ?")
        CURRENTQUESTIONINDEX = 0
        //qVController.pickerSelectMiddleOption()
        // mezhdu voprosami view
        
        self.betweenQuestionView = qVController.betweenQuestionView
        betweenQuestionView.isHidden = true
        /*self.betweenQuestionView = UIView(frame: qVController.picker.frame)
        betweenQuestionView.backgroundColor = UIColor.green
        betweenQuestionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        betweenQuestionView.tag = 1 // the tag to remove
        betweenQuestionView.isHidden = true
        qVController.view.addSubview(betweenQuestionView) */
    }
}



// do novogo goda ne, eto mesyac, kakraz dazvno uzhe nuzhna pauza, pod mastyu uzhe podplavilo prilozhuhu delat a delat nado
// pri etom pomnyu kak eto bilo produktivno na chistuyu, film odin doma, ng s pacanami i pervogo chisla raskur, za mesyac podgotovit k apstoru, treshi, relief na kreshenie, zamenim eto skakalochkoi

//NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(seconds), target: self, selector: selector, userInfo: nil, repeats: false)



/// RIGHT 1394 (1407) 1430 1473 1440       WRONG 1053 1006

/// click 1057    1103    1130

/// 1128        1129 trnasition from to sound 1109 1018 1303

/// 1429 picker scroll

/// 1335 1368 1383 achiev 1034 1035

/// game done 1332
// 1052 1431 1433 right





