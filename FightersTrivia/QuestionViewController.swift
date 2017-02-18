//
//  QuestionViewController.swift
//  Guess the Fighter, Угадай Бойца
//
//  Created by Artem on 11/14/16.
//  Copyright © 2016 piqapp. All rights reserved.

///FONTS///

// Avenir-LightOblique  AvenirNext-UltraLight Didot-Bold HelveticaNeue-UltraLight PingFangHK-Ultralight PingFangTC-Thin


import UIKit

func setupGradient(_ layerAttachTo: CALayer, frame: CGRect, gradient: CAGradientLayer, colors: [CGColor], locations: [NSNumber], startPoint: CGPoint, endPoint: CGPoint, zPosition: Float) {
    
    gradient.frame = frame
    gradient.colors = colors
    gradient.locations = locations
    gradient.startPoint = startPoint
    gradient.endPoint = endPoint
    gradient.zPosition = CGFloat(zPosition)
    layerAttachTo.addSublayer(gradient)
}



var qVController: QuestionViewController!

class QuestionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var fighterNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet var signX: [UIImageView]!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var congratulationsLabel: UILabel!
    @IBOutlet weak var congratStrip: UIStackView!
    //@IBOutlet weak var dotsStack: UIStackView!
    @IBOutlet weak var betweenQuestionView: UIView!
    @IBOutlet weak var moreInfoButton: UIButton!
    
    
    var gradient: CAGradientLayer!
    var currentSelectedAnswer: String!
    var currentRowIndex: Int = 0
    var congratStripOpenConstraint: NSLayoutConstraint!
    var congratStripCloseConstraint: NSLayoutConstraint!
    var answerStripOpenConstraint: NSLayoutConstraint!
    var answerStripCloseConstraint: NSLayoutConstraint!
    var phrases: [String] = [String]()
    var isBetweenQuestions: Bool = false
    var soundMute: Bool?
    
    /////////////////////////// VIEW /////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qVController = self
        ///dlya togo chtobi gradient menyal orientaciyu pri izmenenii raskladki
        NotificationCenter.default.addObserver(self, selector: #selector(QuestionViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        phrases = ["Yes!", "Exactly!", "Well Done!", "Okay!", "Fine!", "Right!", "True!"]
        ///nastroiki gradienta knopki NEXT, on statichniy
        self.answerButtonGradient()
        ///uvilichivaem razmeri freima gradienta, cveta location add vse vnutri
        self.selfBackgroundGradientLayerSetup()
        theGameController.viewFighterNameLabel = fighterNameLabel
        theGameController.scoreLabel = scoreLabel
        self.congratuLationStripAndAnswerButtonsConstraintsInit()
        theGameController.startGame()
        //ubrali eto iz view did apear
    }
    override func viewDidAppear(_ animated: Bool) {
        self.gradientBackgroundColorAnimation()
        self.gradientBackgroundChangePositionAnimation()
        if theGameController.isBetweenQuestionsViewOpen == false {
            setNewImage(theGameController.currentFighter.image)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        // prezhdevremenniy pokaz kartinki, a zatem animacya. uberaet posle web view
        // ubrali eto iz viewDidAppear
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        //gradient.frame = mainView.bounds
        gradientBackgroundColorAnimationStopAndStart()
    }
    
    
    ///////////////////////// PICKER VIEW DELEGATE//////////////// PICKER VIEW DELEGATE//////////////////
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return theGameController.answerListCount
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let title: String!
        title = theGameController.currentAnswerListData[row]
        ///picker rows color and text
        let thetitle = NSAttributedString(string: title, attributes: [NSFontAttributeName:UIFont(name: "PingFangTC-Thin", size: 22.0)!,NSForegroundColorAttributeName:UIColor.white])
        //let hue = CGFloat(1.0 / CGFloat(row))
        pickerLabel.backgroundColor = UIColor(hue: CGFloat(0.7), saturation: 1.0, brightness: 1.0, alpha: 0.65)
        //pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 0.65)
        pickerLabel.textAlignment = .center
        pickerLabel.attributedText = thetitle
        return pickerLabel
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if self.isBetweenQuestions == true {
            return
        }
        
        if self.currentRowIndex != row {    ///esli smestilis na novuyu yacheiku
            theGameController.playSound("SCROLL")
            
        }
        
        let cubeAnimationTransitionDirection: AnimationDirection = (row > self.currentRowIndex) ? .positive : .negative
        
        self.currentSelectedAnswer = theGameController.currentAnswerListData[row]
        
        if self.currentRowIndex != row {    ///esli smestilis na novuyu yacheiku
            ///pri vibore v pickere obnovlyaem label s fighter name
            self.refreshCurrentFighterNameLabelWithAnimation(self.currentSelectedAnswer, animationDirection: cubeAnimationTransitionDirection)
        }
        
        self.currentRowIndex = row
        
    }
    
    // //////////////////////////////////////////// CUSTOM FUNCTIONS ///////////////////////////////////////
    
    func refreshCurrentFighterNameLabel(_ newLabelText: String) {
        self.fighterNameLabel.text = newLabelText
    }
    
    
    func refreshCurrentFighterNameLabelWithAnimation(_ newLabelText: String, animationDirection: AnimationDirection) {
        
        self.fighterNameLabel.text = newLabelText
        cubeTransition(label: self.fighterNameLabel, text: newLabelText, direction: animationDirection)
    }
    
    ///// CUBE TRANSITION ANIMATION ////// ///// ///// /////
    
    enum AnimationDirection: Int {
        case positive = 1
        case negative = -1
    }
    
    // anim changing fighter title label with cube transition
    func cubeTransition(label: UILabel, text: String, direction: AnimationDirection) {
        
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.text = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.textColor = label.textColor
        auxLabel.backgroundColor = label.backgroundColor
        auxLabel.lineBreakMode = .byClipping
        
        let auxLabelOffset = CGFloat(direction.rawValue) *
            label.frame.size.height/2.0
        
        auxLabel.transform = CGAffineTransform(scaleX: 1.0, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: auxLabelOffset))
        
        label.superview!.addSubview(auxLabel)
        ///
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            auxLabel.transform = CGAffineTransform.identity
            label.transform = CGAffineTransform(scaleX: 1.0, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: -auxLabelOffset))
        }, completion: {_ in
            label.text = auxLabel.text
            label.transform = CGAffineTransform.identity
            
            auxLabel.removeFromSuperview()
        })
        
    }
    
    /////   /////   //////  /////// //////  ////
    
    func doSegueWithIdentifier(_ identif: String)
    {
        performSegue(withIdentifier: identif, sender: nil)
    }
    
    ///parametr lishniy         ///GRADIENT COLOR CHANGE IF WRONG
    func backGroundColorChangeAnimationOnAnswer(_ playerAnswerResult: String) {
        ///ne ispulzuetsya potomu chto dinamichniy zadniy background ne pozvolyaet eto, tak chto return
        ///eshe odin horoshiy variant pri oshibke, gradient menyaetsya na protivopolozhniy po simmetrii
        return  ///////////// Testing
        let anim = CABasicAnimation(keyPath: "colors")
        anim.toValue = [UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.blue.cgColor]
        anim.fromValue = [UIColor.red.cgColor, UIColor.red.cgColor, UIColor.red.cgColor]
        anim.duration = 1.5
        anim.repeatCount = 1
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        self.gradient.add(anim, forKey: nil)
        
        /// Predidushiy variant animacii pri oshibke v otvete. bckr s krasnogo na siniy
        
        /*let anim = CABasicAnimation(keyPath: "backgroundColor")
         
         switch playerAnswerResult {
         case "WRONG":
         anim.fromValue = UIColor.redColor().CGColor
         break
         default: break
         }
         anim.toValue = UIColor.blueColor().CGColor
         anim.duration = 1.5
         anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
         anim.repeatCount = 1
         self.gradientView.bacgroundcolor = blueColor()
         */
    }
    
    ///GRADIENT BACGR MIDDLE STRIP ANIM COLOR CHANGE   /// unused
    func gradientBackgroundColorAnimation() {
        
        let anim = CABasicAnimation(keyPath: "colors")
        ///1.
        anim.fromValue = [UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor]
        anim.toValue = [UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.blue.cgColor]
        
        //anim.fromValue = [UIColor.blueColor().CGColor, UIColor.redColor().CGColor, UIColor.blueColor().CGColor]
        //anim.toValue = [UIColor.redColor().CGColor, UIColor.blueColor().CGColor, UIColor.redColor().CGColor]
        
        anim.duration = 8
        anim.repeatCount = Float.infinity
        anim.autoreverses = true
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.gradient.add(anim, forKey: "asd")
    }
    
    func gradientBackgroundColorAnimationStopAndStart() {
        gradient.removeAnimation(forKey: "asd")
        //self.gradient.removeAllAnimations()
        gradientBackgroundColorAnimation()
    }
    
    func gradientBackgroundChangePositionAnimation() {
        let anim = CABasicAnimation(keyPath: "locations")
        anim.fromValue = [0.0, 0.0, 0.25]
        anim.toValue = [0.75, 1.0, 1.0]
        anim.duration = 15
        //anim.autoreverses = true
        anim.repeatCount = Float.infinity
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.gradient.add(anim, forKey: nil)
    }
    
    
    ////// ANSWER BUTTON TITTLE SET ...
    
    func answerButtonSetState(_ state: String) {
        
        if theGameController.gameIsOver == true {
            return
        }
        switch state {
        case "OPEN":
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7, options: [], animations: {
                if self.answerStripOpenConstraint.isActive == false {
                    self.answerStripOpenConstraint.isActive = true
                    self.answerStripCloseConstraint.isActive = false
                }
                self.view.layoutIfNeeded()          ///      ///       ///     ///
                // //////////////////////////////lllllllllllllllllllllllllllllll//
                self.answerButton.setTitle("NEXT", for: UIControlState())
            }, completion: { _ in
            })
            
            break
        case "CLOSE":
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7, options: [], animations: {
                if self.answerStripCloseConstraint.isActive == false {
                    self.answerStripCloseConstraint.isActive = true
                    self.answerStripOpenConstraint.isActive = false
                }
                self.view.layoutIfNeeded()
                self.answerButton.setTitle("", for: UIControlState())
            }, completion: { _ in
            })
            break
        default:
            break
        }
        
    }
    
    func congratStripSetState(_ state: String) {
        if theGameController.gameIsOver == true {
            return
        }
        self.setRandomPhrase() /// SET RAAAANDOM PHRASEEEE
        switch state {
        case "OPEN":
            UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                if self.congratStripCloseConstraint.isActive == true {
                    self.congratStripCloseConstraint.isActive = false
                    self.congratStripOpenConstraint.isActive = true
                }
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
            break
        case "CLOSE":
            UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                if self.congratStripOpenConstraint.isActive == true {
                    self.congratStripOpenConstraint.isActive = false
                    self.congratStripCloseConstraint.isActive = true
                }
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                /// PICKER USER INTERACTION ENABLED
            })
            break
        default:
            break
        }
    }
    
    
    func changeFighterImageWithAnimation(_ toImage: UIImage) {
        
        if theGameController.gameIsOver == true {
            return
        }
        self.imageView.image = toImage
        imageView.image = toImage
        let pos = imageView.layer.position.y
        let anim = CASpringAnimation(keyPath: "position.y")
        anim.damping = 9.1
        anim.initialVelocity = 15.0
        anim.stiffness = 150.0
        anim.mass = 1.0
        anim.duration = anim.settlingDuration
        anim.fromValue = pos - 300
        anim.toValue = pos
        self.imageView.layer.add(anim, forKey: nil)
    }
    
    
    func imageViewFlyDownAnimation() {
        if theGameController.gameIsOver == true {
            return
        }
        
        let pos = imageView.layer.position.y
        let animMove = CASpringAnimation(keyPath: "transform.scale")
        animMove.fromValue = 2.0
        animMove.toValue = 1.0
        animMove.duration = animMove.settlingDuration
        animMove.damping = 8.0
        
        self.fighterNameLabel.layer.add(animMove, forKey: nil)
    }
    
    func pickerSelectMiddleOption() {
        let index: Int = Int(theGameController.answerListCount/2)
        picker.selectRow(index, inComponent: 0, animated: true)
        self.currentSelectedAnswer = theGameController.currentAnswerListData[picker.selectedRow(inComponent: 0)]
    }
    
    func reloadPickerView() {
        self.picker.reloadAllComponents()
    }
    
    func setNewImage(_ imageName: String) {
        // MARK: - change image sound and etc.
        if (theGameController != nil && theGameController.isBetweenQuestionsViewOpen == false){
            theGameController.playSound("CHANGEIMAGE")
        }
        let image = UIImage(named: imageName)!
        self.changeFighterImageWithAnimation(image)
        self.pickerSelectMiddleOption()
    }
    
    func resetDots() {
        self.signX[2].image = UIImage(named: "singleDot")
        self.signX[1].image = UIImage(named: "singleDot")
        self.signX[0].image = UIImage(named: "singleDot")
        
        self.signX[2].transform = CGAffineTransform.identity
        self.signX[2].transform = CGAffineTransform.identity
        self.signX[2].transform = CGAffineTransform.identity
    }
    
    func congratStripConstraintsSetToClose() {
        self.congratStripOpenConstraint.isActive = false
        self.congratStripCloseConstraint.isActive = true
    }
    
    func changeXtoDot() {
        if (theGameController.fightersCount - 1 >= theGameController.CURRENTQUESTIONINDEX) {
            /// GAME OVER
            theGameController.checkForPlayerGameOver(delayToGameOverAnimation: 1.0)
        }
        switch (theGameController.triesLeft) {
        case 2:
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                self.signX[2].center.y -= self.view.bounds.height / 5
            }, completion: { _ in
                self.signX[2].image = UIImage(named: "X1")
                UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.8, options: [], animations: {
                    self.signX[2].center.y += self.view.bounds.height / 5
                }, completion: nil)
            })
            break
        case 1:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                self.signX[1].center.y -= self.view.bounds.height / 5
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.8, options: [], animations: {
                    self.signX[1].image = UIImage(named: "X1")
                    self.signX[1].center.y += self.view.bounds.height / 5
                }, completion: nil)
            })
            break
        case 0:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                self.signX[0].center.y -= self.view.bounds.height / 5
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.8, options: [], animations: {
                    self.signX[0].image = UIImage(named: "X1")
                    self.signX[0].center.y += self.view.bounds.height / 5
                }, completion: nil)
            })
            break
        default:
            break
        }
    }
    
    func answerButtonAnimationIfWrongForGradients() {
        self.answerButton.backgroundColor = UIColor.red
        self.answerButton.center.y -= self.answerButton.bounds.height
        UIView.animate(withDuration: 1.0, animations: {
            self.answerButton.backgroundColor = UIColor.clear
            self.answerButton.center.y += self.answerButton.bounds.height
        }, completion: nil)
    }
    
    func answerButtonAnimationIfRightForGradients() {
        self.answerButton.backgroundColor = UIColor.green
        //self.answerButton.center.y -= self.answerButton.bounds.height
        UIView.animate(withDuration: 1.0, animations: {
            self.answerButton.backgroundColor = UIColor.clear
            // self.answerButton.center.y += self.answerButton.bounds.height
        }, completion: nil)
    }
    
    func answerButtonAnimationOnPress() {
        return
        let anim = CASpringAnimation(keyPath: "transform.scale")
        anim.damping = 7.9
        anim.initialVelocity = 15.0
        //anim.stiffness = 100.0
        anim.mass = 1.0
        anim.duration = anim.settlingDuration
        anim.fromValue = 1.2
        anim.toValue = 1.0
        self.answerButton.layer.add(anim, forKey: nil)
    }
    
    
    ////////////////////////////// ANSWER BUTTON HANDLER /////////////////////// HANDLERS ////////////////
    
    @IBAction func answerButton(_ sender: UIButton) {
        ///zdes refresh chtob esli picker sovpal s kartinkoi i pri nazhatii tak i ostayutsya znaki voprosov na leible, t.k. picker ne smeshyalsya i label ne obnovlyalsya
        self.disablePressAnswerButtonForTime()
        self.isBetweenQuestions = true
        answerButtonAnimationOnPress()
        if(theGameController.checkRightOrWrong(answer: self.currentSelectedAnswer)) {
            self.refreshCurrentFighterNameLabel(self.currentSelectedAnswer)
        } else {
            self.refreshCurrentFighterNameLabel("? ? ? ? ?")
        }
        /// answer disable for pressing for 1 second
        self.disablePressAnswerButtonForTime()
    }
    
    @IBAction func returnToQuestionViewController(_ segue: UIStoryboardSegue) {
        
    }
    
    func disablePressAnswerButtonForTime () {
        self.answerButton.isUserInteractionEnabled = false
        let triggerTime = (Int64(NSEC_PER_SEC) * Int64(1))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.answerButton.isUserInteractionEnabled = true
        })
    }
    
    func answerButtonGradient() {
        return
        /// RETURN KNOPKA ANSWER BUDET PROZRACHNOI
        let gradient = CAGradientLayer()
        let newFrame: CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.answerButton.bounds.height)
        gradient.frame = newFrame
        gradient.zPosition = -10
        gradient.colors = [
            UIColor.white.cgColor,
            UIColor.blue.cgColor
        ]
        
        /* repeat the central location to have solid colors */
        gradient.locations = [0, 1.0]
        
        /* make it horizontal */
        gradient.startPoint = CGPoint(x: 0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        self.answerButton.layer.addSublayer(gradient)
    }
    
    
    func selfBackgroundGradientLayerSetup() {
        gradient = CAGradientLayer()
        gradient.colors = [UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.blue.cgColor]
        gradient.locations = [0.0, 0.0, 0.25]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.2)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.8)
        
        /// ( gradien uvilichivaem v shirinu dvoe i stavim po centru (x: - fra.siz.wi) )
        gradient.frame = CGRect(x: -self.view.frame.size.width/3, y: 0.0, width: self.view.frame.size.width*3, height: self.view.frame.size.height)
        gradient.zPosition = -10
        self.gradientView.layer.addSublayer(gradient)
    }
    
    func congratuLationStripAndAnswerButtonsConstraintsInit() {
        congratStripOpenConstraint = NSLayoutConstraint(item: congratStrip, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0.3, constant: 0.0) /// wtf 0.3 a ne 0.2
        
        congratStripCloseConstraint = NSLayoutConstraint(item: congratStrip, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0.0, constant: 0.0)
        
        answerStripOpenConstraint = NSLayoutConstraint(item: answerButton, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0.2, constant: 0.0)
        
        answerStripCloseConstraint = NSLayoutConstraint(item: answerButton, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0.0, constant: 0.0)
        
        congratStripCloseConstraint.isActive = true
        answerStripOpenConstraint.isActive = true
    }
    
    func setRandomPhrase() {
        let rand = Int(arc4random_uniform(UInt32(phrases.count)))
        self.congratulationsLabel.text = self.phrases[rand]
    }
    
    func animateImageViewIfPlayerWrong() {
        let anim = CABasicAnimation()
        anim.fromValue = 1.0
        anim.toValue = 0.0
        anim.duration = 1.0
        self.imageView.layer.add(anim, forKey: nil)
    }
    
    @IBAction func moreInfoPressed(_ sender: UIButton) {
        self.betweenQuestionView.isHidden = true
    }

}
