//
//  GameViewController.swift
//  Signal Process
//
//  Created by Aleksandr Grin on 8/30/18.
//  Copyright © 2018 AleksandrGrin. All rights reserved.
//

import UIKit
import SpriteKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

fileprivate let interstitialAdId:String = "ca-app-pub-5462309909970544/5836784182"

class GameViewController: UIViewController {

    var fullPageAd:GADInterstitial?
    var levelToPlay:Int?
    var wasPaused:Bool = false
    var tapLabel:UILabel?
    var resumeNotification:Notification?

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
            view.backgroundColor = .white
            // Init the scene from our Gamescene class to match the size of the view
            let scene = GameScene(size: self.view!.bounds.size)
            scene.parentViewController = self
            scene.currentLevel = levelToPlay!

            // Set the scale mode to scale to fit the window
            scene.scaleMode = .fill

            // Present the scene
            view.presentScene(scene)

            //Makes sure that zPosition value is taken into account rather than parent-child relation
            // when determining draw order
            view.ignoresSiblingOrder = true
            
            //Subscribe to the notifications telling us that the application becomes inactive or active for pause handling.
            NotificationCenter.default.addObserver(self, selector: #selector(EnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(EnterForeGround), name: UIApplication.didBecomeActiveNotification, object: nil)
            
            //Initial loading of the ad.
            self.reloadInterstitial()
        }
    }
    
    //When the application goes into the background we pause the scene and set our own
    // variable to make sure that we handle the pausing on resume. This is because
    // the application will auto resume the scene unless manually told not to.
    @objc func EnterBackground(){
        self.wasPaused = true
        (self.view as! SKView).scene!.alpha = 0.4
        (self.view as! SKView).scene!.isPaused = true
    }
    
    //Called when the application becomes active to display a view telling the players
    // how to resume the game.
    @objc func EnterForeGround(){
        if self.wasPaused == true {
            (self.view as! SKView).scene!.isPaused = true
            if self.tapLabel == nil {
                let view = UILabel(frame: CGRect(x: self.view.frame.width / 2 - 135, y: self.view.frame.height / 5, width: 300, height: 100))
                view.text = "Tap to Resume"
                view.font = UIFont(name: "Helvetica-Bold", size: 36)
                view.contentMode = .center
                view.alpha = 0
                self.tapLabel = view
                self.view.addSubview(view)
            }
            UIView.animate(withDuration: 0.5, animations: { self.tapLabel!.alpha = 1.0 })
        }
    }
    
    //Will handle resuming the game scene and sending the resume notification for the game timer.
    // This is necessary because the timer is not paused with the scene so we have to handle it
    // manually.
    func handleGameResume(){
        if self.resumeNotification == nil {
            self.resumeNotification = Notification(name: Notification.Name.init(rawValue: "ResumeGame"), object: nil, userInfo: nil)
        }
        NotificationCenter.default.post(self.resumeNotification!)

        (self.view as! SKView).scene!.isPaused = false
        if self.tapLabel != nil {
            self.tapLabel!.alpha = 0
            self.wasPaused = false
            (self.view as! SKView).scene!.alpha = 1.0
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
    
    
}

extension GameViewController:GADInterstitialDelegate{
    //Interstitial Ads need to be renewed after each showing so we have to reload it by making
    // a new object.
    func reloadInterstitial(){
        self.fullPageAd = nil
        let interstitial = GADInterstitial(adUnitID: interstitialAdId)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        self.fullPageAd = interstitial
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        (self.view as! SKView).scene?.isPaused = true
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        (self.view as! SKView).scene?.isPaused = false
        
        //Load the interstitial ad on a different thread so as not to interfere with
        // the game.
        DispatchQueue.main.async { [unowned self] in
            self.reloadInterstitial()
        }
    }
    
    //Handles presenting the full screen ad if it was successfully loaded.
    func presentFullScreenAd(){
        if let ad = self.fullPageAd {
            if ad.isReady {
                ad.present(fromRootViewController: self)
            }
        }
    }
}
