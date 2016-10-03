var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var User = require('./user.js');
var Database = require('./database.js');
var db = new Database();
var ServerError = require('./server_error.js');
var serverError = new ServerError();

//minimum clients required for playing the game
var CLIENTS_MIN = 2;
//maximum clients required for playing the game
var CLIENTS_MAX = 50;
//socket messages
var START_GAME = "startGame";
var START_ROUND = "startRound";
var TICK = "tick";
var CONNECT_USER = "connectUser";
var END_GAME = "endGame";
var RESPONSE = "response";
var PREPARE_FOR_ROUND = "prepareRound";
var SEND_SCORE = "sendScore";
var SEND_ERROR = "sendError";

var ROUND_DURATION = 15000;
var ROUNDS = 8;
var START_GAME_DELAY = 1000;
var PREPARE_DELAY = 2000;

//array with User objects
var userList = [];
var currentRound = 0;
var selectedMovie = {};
var tick;
var tickInterval;
var error = 0;

app.get('/', function(req, res){
  res.send('<h1>MovieTrivia</h1>');
});

http.listen(3000, function(){
  console.log('Listening on *:3000');
});


io.on('connection', function(clientSocket){
  console.log('A user connected: waiting for nickname');
  //receive nickname from client
  clientSocket.on(CONNECT_USER, function(clientNickname) {
      var message = "User " + clientNickname + " was connected.";
      console.log(message);

	  var user;
      var foundUser = false;
      for (var i=0; i<userList.length; i++) {
        if (userList[i].name == clientNickname) {
          userList[i].isConnected = true
          userList[i].id = clientSocket.id;
          user = userList[i];
          foundUser = true;
          break;
        }
      }

      if (!foundUser) {
		user = new User();
		user.id = clientSocket.id;
		user.name = clientNickname;
		user.isConnected = true;
		user.score = 0;
        userList.push(user);
      }
	  
	  if(userList.length >= CLIENTS_MIN && userList.length < CLIENTS_MAX){
	  	  startGame();
	  }
  });
  //client disconnects
  clientSocket.on('disconnect', function(){
	var index;
    for (var i=0; i<userList.length; i++) {
      if (userList[i].id == clientSocket.id) {
		  index = i;
        break;
      }
    }
	clientSocket.disconnect(true);
	console.log("user "+ userList[index].name +" disconnected");
	userList.splice(index, 1);
	checkForError();
  });
  
  
  //receive response from client
  clientSocket.on(RESPONSE, function(clientNickname, response) {
      var message = "User " + clientNickname + " response is: " + response;
	  console.log(message);
      for (var i=0; i<userList.length; i++) {
        if (userList[i].name == clientNickname) {
			if(selectedMovie.year == response){
				console.log("User "+ clientNickname + ": OK! Score: " + userList[i].score);
				userList[i].score += 5;
			} else {
				console.log("User " + clientNickname + ": NOK! Score: " + userList[i].score);
				userList[i].score -= 3;
			}
			console.log("broadcast score to "+userList[i].name);
			io.to(userList[i].id).emit(SEND_SCORE, userList[i].score);
			break;
		}
	}
      
  });

});

//check error
var checkForError = function () {	
	
	var errorOccured = false;
	if(userList.length < CLIENTS_MIN){
		error = 1;
		io.emit(SEND_ERROR, serverError.errors[error-1].description);
		errorOccured = true;
    }
	if(errorOccured){
		console.log("ERROR OCCURED -> RESET EVERYTHING");
	}
	return errorOccured;
}

//start new game
var startGame = function () {
	console.log("FSM:START GAME"); 
	if(checkForError()){
		return;
	}
	
	currentRound = 0;
	tick = 0;
	io.emit(START_GAME, START_GAME_DELAY);
	
	//reset score
	for (var i=0; i<userList.length; i++){
		userList[i].score = 0;
	}
	//send score to players
	sendScore();
	
	setTimeout(prepareGame, PREPARE_DELAY);
}

//prepare for new round or end game
var prepareGame = function(){
	console.log("FSM:PREPARE GAME");
	
	if(tickInterval){
		clearInterval(tickInterval);
	}
	
	if(checkForError()){
		return;
	}
	
	if(currentRound == ROUNDS){ 
		setTimeout(endGame, PREPARE_DELAY);
	} else {
		setTimeout(startRound, PREPARE_DELAY);
		io.emit(PREPARE_FOR_ROUND, PREPARE_DELAY);
	}
}

//start new round
var startRound = function () {
	console.log("FSM:START ROUND");

	if(checkForError()){
		return;
	}
	
	currentRound++;
	
	selectedMovie = db.getRandomMovie();
		
	io.emit(START_ROUND, selectedMovie.name, currentRound); 
		
	tick = ROUND_DURATION;
	sendTick();
	tickInterval = setInterval(sendTick, 1000);
	
	setTimeout(prepareGame, ROUND_DURATION);
}

//end game
var endGame = function(){
	console.log("FSM:END GAME");
	
	if(checkForError()){
		return;
	}
		
	//verify winning player
	var maxScore = -10000;
	for (var i=0; i<userList.length; i++){
		if(userList[i].score > maxScore){
			maxScore = userList[i].score;
		}
	}
	
	for (var i=0; i<userList.length; i++){
		if(userList[i].score == maxScore){
			io.emit(END_GAME, userList[i].name, userList[i].score);
			break;
		}
	}
	setTimeout(startGame, PREPARE_DELAY);
}
//send score to all users
function sendScore() {
	for (var i=0; i<userList.length; i++){
		io.to(userList[i].id).emit(SEND_SCORE, userList[i].score);
	}
}

//send tick
var sendTick = function (){
		tick -= 1000;
		io.emit(TICK, tick/1000);
}

