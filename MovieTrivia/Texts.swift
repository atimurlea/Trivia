//
//  Texts.swift
//  MovieTrivia
//
//  Created by Timurlea Andrei on 02/10/2016.
//  Copyright © 2016 Timurlea Andrei. All rights reserved.
//

import Foundation

/*
 Singleton class with general texts
 */
class Texts: NSObject {
    static let sharedInstance = Texts();
    
    let WELCOME = "Welcome back, "
    let SCORE = "Your score is: "
    let TIMER = "Timer: "
    let SELECTED_MOVIE = "Movie: "
    let PREPARE_FOR_GAME = "Prepare yourself. Game is ready to start!"
    let ROUND = "Round: "
    let PREPARE_FOR_ROUND = "Prepare for next round!"
}
