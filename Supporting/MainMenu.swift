//
// Created by Aleksandr Grin on 1/22/19.
// Copyright (c) 2019 AleksandrGrin. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenuViewController: UIViewController {

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
        gameVC.levelToPlay = level

        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            (self.view as! SKView).scene!.isPaused = true
            self.navigationController?.pushViewController(gameVC, animated: true)
        })
    }
}

class MainMenuScene:SKScene, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{

    var startButton:SKSpriteNode?
    var chosenLevel:Int = 0
    weak var parentVC:MainMenuViewController?

    let pickerRowHeight:CGFloat = 100
    let pickerRowWidth:CGFloat = 100
    let pickerData:[Int] = {
        var levels:[Int] = []
        for i in 0..<100{
            levels.append(i)
        }
        return levels
    }()

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        let test = SKLabelNode(text: "Signal Process")
        test.position = CGPoint(x: self.view!.bounds.size.width / 2, y: self.view!.bounds.size.height / 4 * 3)
        self.addChild(test)

        self.startButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 40))
        startButton!.position = CGPoint(x: self.view!.bounds.size.width / 2, y: self.view!.bounds.size.height / 2)
        self.addChild(self.startButton!)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view!.addGestureRecognizer(tapGesture)

        let picker = UIPickerView(frame: CGRect(x: self.view!.bounds.width/2 - 150, y: self.view!.bounds.height/4*2.5, width: 300, height: self.pickerRowHeight))
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .clear
        picker.isOpaque = true
        self.view!.addSubview(picker)

        picker.transform = CGAffineTransform(rotationAngle: -90 * (.pi/180))
        picker.frame = CGRect(x: 0, y: self.view!.bounds.height/4*2.5, width: self.view!.bounds.size.width, height: self.pickerRowHeight)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.chosenLevel = self.pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self.pickerRowHeight
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.pickerRowWidth, height: self.pickerRowHeight))

        let top = UILabel(frame: CGRect(x: 0, y: 25, width: self.pickerRowWidth, height: 15))
        top.text = "Level"
        top.textAlignment = .center
        top.textColor = .white
        top.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        view.addSubview(top)

        let main = UILabel(frame: CGRect(x: 0, y: 0, width: self.pickerRowWidth, height: self.pickerRowHeight))
        main.text = "\(self.pickerData[row] + 1)"
        main.textAlignment = .center
        main.textColor = .white
        main.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        view.addSubview(main)

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
            if self.startButton?.contains(tapLocation) ?? false{
                if parentVC != nil{
                    parentVC!.transitionToGame(with: self.chosenLevel)
                }
            }
        }
    }
}
