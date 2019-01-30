//
// Created by Aleksandr Grin on 1/22/19.
// Copyright (c) 2019 AleksandrGrin. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class MainMenuViewController: UIViewController {
    
    var topBannerViewAd:GADBannerView?
    var bottomBannerViewAd:GADBannerView?
    
    override func viewWillAppear(_ animated: Bool) {
        //Set the navigation bar to hidden before the view appears so the user never notices.
        self.navigationController?.isNavigationBarHidden = true
    }

    override func loadView() {
        //Since we are initializing without a storyboard we manually create the view here.
        // In this case since we know we will be using spritekit we skip to SKView not UIView.
        self.view = SKView()
        //This is the point size of the iphone X screen dimensions (POINTS! not PIXELS!)
        self.view.bounds.size = CGSize(width: 375, height: 812)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            // Init the scene from our Gamescene class to match the size of the view
            let scene = MainMenuScene(size: self.view!.bounds.size)
            scene.parentVC = self
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .fill

            // Present the scene
            view.presentScene(scene)

            //Makes sure that zPosition value is taken into account rather than parent-child relation
            // when determining draw order
            view.ignoresSiblingOrder = true

            //Debug information for development
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsDrawCount = true
        }
        
        //The ad setup can be run async just to make sure no performance is impacted.
        DispatchQueue.main.async { [unowned self] in
            self.initializeBannerAds()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    //Determine the allowed orientations of the device when running the app
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func transitionToGame(with level:Int){
        let gameVC = GameViewController()
        gameVC.modalTransitionStyle = .flipHorizontal
        gameVC.levelToPlay = level

        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            (self.view as! SKView).scene!.isPaused = true
            self.navigationController?.pushViewController(gameVC, animated: true)
        })
    }
}

extension MainMenuViewController: GADBannerViewDelegate {
    
    private func initializeBannerAds(){
        //Initialize top banner ad
        self.topBannerViewAd = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        self.topBannerViewAd!.translatesAutoresizingMaskIntoConstraints = false
        self.topBannerViewAd!.delegate = self
        //Banner is initially hidden.
        self.topBannerViewAd!.alpha = 0.0
        self.view.addSubview(self.topBannerViewAd!)
        
        //These two constraints will center the ad banner and place it at the top safe area of the app.
        NSLayoutConstraint(item: self.topBannerViewAd!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: self.topBannerViewAd!, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .topMargin, multiplier: 1.0, constant: 0.0).isActive = true
        
        self.topBannerViewAd!.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        self.topBannerViewAd!.rootViewController = self
        self.topBannerViewAd!.load(GADRequest())
        
        //Initialize bottom banner ad
        self.bottomBannerViewAd = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        self.bottomBannerViewAd!.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBannerViewAd!.delegate = self
        //Banner is initially hidden.
        self.bottomBannerViewAd!.alpha = 0.0
        self.view.addSubview(self.bottomBannerViewAd!)
        
        //These two constraints will center the ad banner and place it at the top safe area of the app.
        NSLayoutConstraint(item: self.bottomBannerViewAd!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: self.bottomBannerViewAd!, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottomMargin, multiplier: 1.0, constant: 0.0).isActive = true
        
        self.bottomBannerViewAd!.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        self.bottomBannerViewAd!.rootViewController = self
        self.bottomBannerViewAd!.load(GADRequest())
    }
    
    //Check if the app has recieved an ad. If it has then fade the ad banner in and display the ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            bannerView.alpha = 1
        })
    }
    
    //If an ad has not appeared
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }
}


class MainMenuScene:SKScene, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{

    var startButton:SpriteButton?
    var showLetterButton:SpriteButton?
    var selectedLevel:SKLabelNode?
    var chosenLevel:Int = 0
    weak var parentVC:MainMenuViewController?

    let pickerRowHeight:CGFloat = 100
    let pickerRowWidth:CGFloat = 100
    
    var signalTower:SKSpriteNode?
    var playerSignal:SKSpriteNode?
    var playerLine:SKShapeNode?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let background = SKSpriteNode(imageNamed: "MainMenu.png")
        background.zPosition = -1
        background.size = self.size
        background.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        background.position = CGPoint.zero
        self.addChild(background)
        
        let mainScreen = SKSpriteNode(color: .black, size: CGSize(width: 300, height: 220))
        mainScreen.alpha = 0.90
        mainScreen.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mainScreen.zPosition = 1
        mainScreen.position = CGPoint(x: self.size.width / 2 + 43, y: self.size.height / 1.835)
        self.addChild(mainScreen)
        mainScreen.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.run {
                mainScreen.color = .white
            },
            SKAction.fadeAlpha(to: 0.50, duration: 1.0)
            ]))
        
        let mainSelectionScreen = SKSpriteNode(color: .black, size: CGSize(width: 300, height: 130))
        mainSelectionScreen.alpha = 0.90
        mainSelectionScreen.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mainSelectionScreen.zPosition = 1
        mainSelectionScreen.position = CGPoint(x: self.size.width / 2 + 15, y: self.size.height / 3.42)
        self.addChild(mainSelectionScreen)
        mainSelectionScreen.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.run {
                mainSelectionScreen.color = .white
            },
            SKAction.fadeAlpha(to: 0.50, duration: 1.0)
            ]))

        self.startButton = SpriteButton(button: SKTexture(imageNamed: "Button"), buttonTouched: SKTexture(imageNamed: "Button_Touched"))
        startButton!.setButtonText(text: "Start Signal")
        startButton!.setButtonScale(to: 0.35)
        startButton!.zPosition = 2
        startButton!.alpha = 0
        startButton!.position = CGPoint(x: self.view!.bounds.size.width / 2 + 80, y: self.view!.bounds.size.height / 2 + 25 )
        self.addChild(self.startButton!)
        startButton!.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.fadeIn(withDuration: 1.0)]))
        
        self.showLetterButton = SpriteButton(button: SKTexture(imageNamed: "Button"), buttonTouched: SKTexture(imageNamed: "Button_Touched"))
        showLetterButton!.setButtonText(text: "Tecla's Letter")
        showLetterButton!.setButtonScale(to: 0.35)
        showLetterButton!.zPosition = 2
        showLetterButton!.alpha = 0
        showLetterButton!.position = CGPoint(x: self.view!.bounds.size.width / 2 + 80, y: self.view!.bounds.size.height / 2 - 28)
        self.addChild(self.showLetterButton!)
        showLetterButton!.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.fadeIn(withDuration: 1.0)]))
        
        self.signalTower = SKSpriteNode(imageNamed: "Tower_Off.png")
        self.signalTower!.setScale(0.45)
        self.signalTower!.zPosition = 2
        self.signalTower!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        self.signalTower!.alpha = 0.0
        self.signalTower!.position = CGPoint(x: self.size.width / 2.7, y: self.size.height / 2.4)
        self.addChild(self.signalTower!)

        self.selectedLevel = SKLabelNode(text: "Selected Level 1")
        self.selectedLevel!.fontColor = .black
        self.selectedLevel!.fontName = UIFont.systemFont(ofSize: 8, weight: .medium).fontName
        self.selectedLevel!.fontSize = 16
        self.selectedLevel!.position = CGPoint(x: self.size.width / 2 + 18, y: self.size.height / 6 - 29)
        self.selectedLevel!.alpha = 0
        self.selectedLevel!.zPosition = 2
        self.addChild(self.selectedLevel!)
        
        let selectedScreen = SKSpriteNode(color: .black, size: CGSize(width: 160, height: 38))
        selectedScreen.alpha = 0.90
        selectedScreen.zPosition = 1
        selectedScreen.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        selectedScreen.position = CGPoint(x: self.size.width / 1.79, y: self.size.height / 7.2)
        self.addChild(selectedScreen)
        self.run(SKAction.sequence([
            SKAction.run {
                selectedScreen.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.75),
                    SKAction.run {
                        selectedScreen.color = .white
                    },
                    SKAction.fadeAlpha(to: 0.50, duration: 0.75)
                    ]))
            },
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                self.selectedLevel!.run(SKAction.fadeIn(withDuration: 0.75))
            },
            SKAction.run {
                self.signalTower!.run(SKAction.fadeAlpha(to: 0.8, duration: 0.75))
            }
            ]))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view!.addGestureRecognizer(tapGesture)

        let picker = UIPickerView(frame: CGRect(x: self.view!.bounds.width/3, y: self.view!.bounds.height/4*3, width: self.pickerRowWidth, height: self.pickerRowHeight))
        picker.delegate = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.backgroundColor = .clear
        picker.isOpaque = true
        picker.alpha = 0
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                UIView.animate(withDuration: 1.0, animations: {
                    picker.alpha = 1.0
                })
        }]))
        self.view!.addSubview(picker)
        
        picker.transform = CGAffineTransform(rotationAngle: -90 * (.pi/180))
        NSLayoutConstraint(item: picker, attribute: .centerX, relatedBy: .equal, toItem: self.view!.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1.0, constant: 10).isActive = true
        NSLayoutConstraint(item: picker, attribute: .centerY, relatedBy: .equal, toItem: self.view!.safeAreaLayoutGuide, attribute: .centerY, multiplier: 1.0, constant: 160).isActive = true
        NSLayoutConstraint(item: picker, attribute: .width, relatedBy: .equal, toItem: self.view!.safeAreaLayoutGuide, attribute: .width, multiplier: 0.3, constant: 0).isActive = true
        NSLayoutConstraint(item: picker, attribute: .height, relatedBy: .equal, toItem: self.view!.safeAreaLayoutGuide, attribute: .height, multiplier: 0.50, constant: 0).isActive = true
    
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if GameData.sharedInstance().levelData[row].unlocked == true{
            self.selectedLevel!.text = "Selected Level \(row+1)"
            self.chosenLevel = row
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GameData.sharedInstance().levelData.count
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self.pickerRowHeight
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.pickerRowWidth, height: self.pickerRowHeight))

        let top = UILabel(frame: CGRect(x: 0, y: 10, width: self.pickerRowWidth, height: 15))
        top.text = "Level"
        top.textAlignment = .center
        top.textColor = .black
        top.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        view.addSubview(top)

        let main = UILabel(frame: CGRect(x: 0, y: -10, width: self.pickerRowWidth, height: self.pickerRowHeight))
        main.text = "\(row + 1)"
        main.textAlignment = .center
        main.textColor = .black
        main.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        view.addSubview(main)
        
        let cityName = UILabel(frame: CGRect(x: 0, y: 58, width: self.pickerRowWidth, height: 15))
        cityName.text = GameData.sharedInstance().levelData[row].cityName
        cityName.textAlignment = .center
        cityName.textColor = .black
        cityName.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        view.addSubview(cityName)

        let bottom = UILabel(frame: CGRect(x: 0, y: 80, width: self.pickerRowWidth, height: 15))
        if GameData.sharedInstance().levelData[row].unlocked {
            bottom.text = "\(GameData.sharedInstance().levelData[row].highScore)"
        }else{
            bottom.text = "Locked"
        }
        bottom.textAlignment = .center
        bottom.textColor = .black
        bottom.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        view.addSubview(bottom)

        view.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
        return view
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    @objc func handleTap(_ sender:UITapGestureRecognizer){
        let coordinates = sender.location(in: self.view!)
        let tapLocation = self.convertPoint(fromView: coordinates)

        if self.startButton != nil{
            if self.startButton!.contains(tapLocation){
                if parentVC != nil{
                    self.startButton!.buttonTouchedUpInside(completion: {})
                    self.run(SKAction.sequence([
                        SKAction.run {
                            self.activateGame()
                        },
                        SKAction.wait(forDuration: 0.5),
                        SKAction.run {
                            self.parentVC!.transitionToGame(with: self.chosenLevel)
                        }]))
                }
            }
        }
        if self.showLetterButton != nil{
            if self.showLetterButton!.contains(tapLocation) {
                if parentVC != nil{
                    self.showLetterButton!.buttonTouchedUpInside {
                        let letter = OpeningScreenViewController()
                        letter.isPresentedFromMenu = true
                        self.parentVC!.navigationController!.present(letter, animated: true, completion: {})
                    }
                }
            }
        }
    }
    
    //When transitioning from the Game screen back to menu we need to reset all the fancy
    // effects to prepare to launch again. Basically we are reloading.
    func resetMainMenu(){
        self.removeAllActions()
        self.playerLine!.removeFromParent()
        self.playerSignal!.removeFromParent()
        self.playerSignal = nil
        self.playerLine = nil
        self.signalTower!.texture = SKTexture(imageNamed: "Tower_Off.png")
    }
    
    //This is essentially an animation to show that the game is starting when the player
    // types start.
    func activateGame(){
        self.signalTower!.texture! = SKTexture(imageNamed: "Tower_On.png")
        self.playerSignal = SKSpriteNode(color: .red, size: CGSize(width: 10, height: 10))
        self.playerSignal!.zPosition = 2
        self.playerSignal!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.playerSignal!.alpha = 0.80
        self.playerSignal!.position = CGPoint(x: self.size.width / 2.6, y: self.size.height / 2 + 85)
        self.addChild(self.playerSignal!)
        
        self.playerLine = SKShapeNode()
        self.playerLine!.strokeColor = .white
        self.playerLine!.lineWidth = 8
        self.playerLine!.lineCap = .round
        self.playerLine!.zPosition = 2
        self.playerLine!.alpha = 0.90
        self.playerLine!.strokeTexture = SKTexture(imageNamed: "PlayerSignalColor.png")
        self.addChild(self.playerLine!)
        
        let dynamicPath = CGMutablePath()
        dynamicPath.move(to: self.playerSignal!.position)
        
        self.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run({
                dynamicPath.addLine(to: self.playerSignal!.position)
                dynamicPath.closeSubpath()
                self.playerSignal!.position.x += 3
                self.playerLine!.path = dynamicPath
                dynamicPath.move(to: self.playerSignal!.position)
            }),
            SKAction.wait(forDuration: 1/120)
        ])))
    }
}
