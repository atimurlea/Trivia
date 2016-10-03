//
//  SocketIOManager.swift
//  MovieTrivia
//
//  Created by Timurlea Andrei on 01/10/2016.
//  Copyright © 2016 Timurlea Andrei. All rights reserved.
//

import Foundation

/*
 Singleton class that handles server messages that are send/received to/from server
 */
class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://timurlea.go.ro:3000")! as URL)
    
    func establishConnection() {
        self.addHandlers();
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func login(nickname: String)  {
        socket.emit(ServerCommands.sharedInstance.CONNECT_USER, nickname)
    }
    
    func sendResponse(nickname:String, response:String){
        socket.emit(ServerCommands.sharedInstance.RESPONSE, nickname, response)
    }
    
    func addHandlers() {
        self.socket.on("connect") {data, ack in
            print("socket connected")
        }
        
        self.socket.on(ServerCommands.sharedInstance.START_GAME) {data, ack in
            if let value = data[0] as? Int {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ServerCommands.sharedInstance.START_GAME), object: value)
            }
        }
        
        self.socket.on(ServerCommands.sharedInstance.PREPARE_FOR_ROUND) {data, ack in
            if let value = data[0] as? Int {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ServerCommands.sharedInstance.PREPARE_FOR_ROUND), object: value)
            }
        }
        
        self.socket.on(ServerCommands.sharedInstance.START_ROUND) {data, ack in
            if let value = data[0] as? String {
                let dict = ["value" : value, "round":data[1] as? Int] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ServerCommands.sharedInstance.START_ROUND), object: value, userInfo:dict)
            }
        }
        
        self.socket.on(ServerCommands.sharedInstance.END_GAME) {data, ack in
            if let value = data[0] as? String {
                let dict = ["name" : data[0] as? String, "score":data[1] as? Int] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ServerCommands.sharedInstance.END_GAME), object: value, userInfo:dict)
            }
        }
        
        self.socket.on(ServerCommands.sharedInstance.SEND_SCORE) {data, ack in
            if let value = data[0] as? Int {
                let dict = ["score":data[0] as? Int] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ServerCommands.sharedInstance.SEND_SCORE), object: value, userInfo:dict)
            }
        }

        
        self.socket.on(ServerCommands.sharedInstance.TICK) {data, ack in
            if let value = data[0] as? Int {
                let dict = ["value" : value]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ServerCommands.sharedInstance.TICK), object: value, userInfo:dict)
            }
        }
        
        self.socket.on(ServerCommands.sharedInstance.RECEIVE_ERROR) {data, ack in
            if let value = data[0] as? String {
                let dict = ["value" : value]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ServerCommands.sharedInstance.RECEIVE_ERROR), object: value, userInfo:dict)
            }
        }
    }
}
