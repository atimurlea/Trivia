//
//  ViewController.swift
//  MovieTrivia
//
//  Created by Timurlea Andrei on 30/09/2016.
//  Copyright © 2016 Timurlea Andrei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var sendResponseButton: UIButton!
    @IBOutlet weak var tickLabel: UITextField!
    @IBOutlet weak var resultTextFileld: UITextField!
    @IBOutlet weak var roundLabel: UILabel!
    
    var nickname: String?
    var endGameAlert:UIAlertController?
    
    
    //MARK: - UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initialize(value: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if nickname == nil {
            askForNickname()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.addNotifications();
    }
    
    func initialize(value:Bool){
        self.nameLabel.isHidden = value
        self.scoreLabel.isHidden = value
        self.movieLabel.isHidden = value
        self.tickLabel.isHidden = value
         self.roundLabel.isHidden = value
        self.resultTextFileld.isHidden = value
        self.sendResponseButton.isUserInteractionEnabled = !value
        self.sendResponseButton.isUserInteractionEnabled = !value
    }

    func askForNickname() {
        let alertController = UIAlertController(title: "Nickname", message: "Please enter a nickname:", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 {
                self.askForNickname()
            }
            else {
                self.nickname = textfield.text
                self.nameLabel.text = Texts.sharedInstance.WELCOME + self.nickname! + "!";
                SocketIOManager.sharedInstance.login(nickname: self.nickname!);
                
                self.initialize(value: false)
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil);
    }
    
    //MARK: Notifications
    func addNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.onStartGame), name:NSNotification.Name(rawValue: ServerCommands.sharedInstance.START_GAME), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onStartRound), name:NSNotification.Name(rawValue: ServerCommands.sharedInstance.START_ROUND), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onEndGame), name:NSNotification.Name(rawValue: ServerCommands.sharedInstance.END_GAME), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSendScore), name:NSNotification.Name(rawValue: ServerCommands.sharedInstance.SEND_SCORE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onTick), name:NSNotification.Name(rawValue: ServerCommands.sharedInstance.TICK), object: nil)
    }
    
    func onStartGame(notification: NSNotification){
        //self.initialize(value: true)
        if(endGameAlert != nil){
            endGameAlert!.dismiss(animated: true, completion: nil)
        }
        self.scoreLabel.text = Texts.sharedInstance.SCORE
        self.roundLabel.text = Texts.sharedInstance.ROUND
        self.movieLabel.text = Texts.sharedInstance.SELECTED_MOVIE
        self.tickLabel.text = Texts.sharedInstance.PREPARE_FOR_GAME
    }
    
    func onStartRound(notification: NSNotification){
        if let info = notification.userInfo as? [String: Any] {
            let value:String = info["value"]! as! String;
            let round:Int = info["round"] as! Int;
            self.movieLabel.text = Texts.sharedInstance.SELECTED_MOVIE + value;
            self.roundLabel.text = Texts.sharedInstance.ROUND + round.description
            self.resultTextFileld.isUserInteractionEnabled = true
            self.sendResponseButton.isUserInteractionEnabled = true
        }
    }
    
    func onEndGame(notification: NSNotification){
        if let info = notification.userInfo {
            let name:String = info["name"]! as! String;
            let score:Int = info["score"]! as! Int;
            
            endGameAlert = UIAlertController(title: "GAME OVER", message: "User \(name) won with a score of \(score)", preferredStyle: UIAlertControllerStyle.alert)
            self.present(endGameAlert!, animated: true, completion: nil);
        }
    }
    
    func onSendScore(notification: NSNotification){
        if let info = notification.userInfo {
            let score:Int = info["score"]! as! Int;
            self.scoreLabel.text = Texts.sharedInstance.SCORE + score.description
        }
    }
    
    func onTick(notification: NSNotification){
        if let info = notification.userInfo {
            let value:Int = info["value"]! as! Int;
            self.tickLabel.text = Texts.sharedInstance.TIMER + value.description
        }
    }
    
    //MARK: - Buttons handlers
    @IBAction func sendResponseToServer(_ sender: AnyObject) {
        let selectedYear = resultTextFileld.text
        self.sendResponseButton.isUserInteractionEnabled = false
        resultTextFileld.resignFirstResponder()
        SocketIOManager.sharedInstance.sendResponse(nickname: self.nickname!, response: selectedYear!)
    }
}

