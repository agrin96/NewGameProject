//
//  OpeningScreen.swift
//  Signal Process
//
//  Created by Aleksandr Grin on 1/25/19.
//  Copyright © 2019 AleksandrGrin. All rights reserved.
//

import SpriteKit
import UIKit

class OpeningScreenViewController: UIViewController {
    
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
            let scene = OpeningScreen(size: self.view!.bounds.size)
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
    
    func transitionToMenu(){
        let mainMenu = MainMenuViewController()
        
        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            (self.view as! SKView).scene!.isPaused = true
            self.navigationController?.pushViewController(mainMenu, animated: true)
        })
    }
}


class OpeningScreen:SKScene, UIGestureRecognizerDelegate {
    
    var startButton:SKSpriteNode?
    weak var parentVC:OpeningScreenViewController?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let background = SKSpriteNode(imageNamed: "OpeningScreen.png")
        background.size = self.size
        background.zPosition = -1
        background.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        background.position = CGPoint.zero
        background.alpha = 0
        self.addChild(background)
        background.run(SKAction.fadeIn(withDuration: 3))
        
        let tapToSkip = SKLabelNode(text: "Tap to Skip")
        tapToSkip.position.x = self.size.width / 2
        tapToSkip.position.y = self.size.height / 14
        tapToSkip.fontSize = 24
        tapToSkip.alpha = 0
        self.addChild(tapToSkip)
        
        tapToSkip.run(SKAction.fadeIn(withDuration: 3))
        
        let tapHandle = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view!.addGestureRecognizer(tapHandle)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        if let vc = self.parentVC {
            vc.transitionToMenu()
        }
    }
}
