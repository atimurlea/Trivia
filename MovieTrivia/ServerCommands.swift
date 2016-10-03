//
//  ServerCommands.swift
//  MovieTrivia
//
//  Created by Timurlea Andrei on 01/10/2016.
//  Copyright © 2016 Timurlea Andrei. All rights reserved.
//

import Foundation

import Foundation

class ServerCommands: NSObject {
    static let sharedInstance = ServerCommands();
    
    let START_GAME = "startGame"
    let START_ROUND = "startRound"
    let TICK = "tick"
    let CONNECT_USER = "connectUser"
    let RESPONSE = "response"
    let END_GAME = "endGame"
    let SEND_SCORE = "sendScore"
    let PREPARE_FOR_ROUND = "prepareRound"
    var RECEIVE_ERROR = "sendError";
}
