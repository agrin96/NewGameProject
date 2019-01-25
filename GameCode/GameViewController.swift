//
//  GameViewController.swift
//  Signal Process
//
//  Created by Aleksandr Grin on 8/30/18.
//  Copyright © 2018 AleksandrGrin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController {

    var fullPageAd:GADInterstitial?
    var levelToPlay:Int?

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
            let scene = GameScene(size: self.view!.bounds.size)
            scene.parentViewController = self
            scene.currentLevel = levelToPlay!

            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill

            // Present the scene
            view.presentScene(scene)

            //Makes sure that zPosition value is taken into account rather than parent-child relation
            // when determining draw order
            view.ignoresSiblingOrder = true

            //Debug information for development
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsDrawCount = true
            
            //Initial loading of the ad.
            self.reloadInterstitial()
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
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
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
