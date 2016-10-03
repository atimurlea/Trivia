# Trivia

For implementation, I used a client server architecture. I used sockets because real time events are sent to the client. Server side is made in Node.js with Express.js and client side is made in Swift.

Technologies and libraries used for server side:
-Node.js : https://nodejs.org
-Express.js : http://expressjs.com

Technologies and libraries used for client side:
-Swift
-Xcode
-Socket.io swift : https://github.com/socketio/socket.io-client-swift

IMPLEMENTATION - Server Side
I tried to simulate a finite state machine in order to manage the application with more ease.

FSM: 
wait -> startGame 
startGame   ->prepareGame
prepareGame ->startRound
 	    ->endGame
startRound  -> prepareGame
endGame     -> wait

Important methods:
-startGame - So, when server runs it waits for users to connect. When minimum users are connected(2), startGame method is called. Here, “startGame” message is sent to client in order to initialise the game. Also, all the users score is set to 0 and “sendScore” message is send to clients with 0 value; As a next event, prepareGame method is called.
-prepareGame - This method verifies if the game is finished or another round can start. Also, it waits a PREPARE_DELAY(2 sec) and announces the client with “prepareRound” message.
-startRound - From database, a random movie is selected and is sent to the client through “startRound” message. A tick is started and at every second the left duration for round is sent to client through “tick” message. After ROUND_DURATION(15 sec), prepareGame is called again.
-endGame - Here, is verified on server which client has the maximum score and “sendScore” message is sent to all clients with the name of the winner client and the score.
-sendScore - send “sendScore” message at every client with score data

CLasses used:
User - store data about client users
Database - database with movies from db.txt
ServerErrors - class with errors. When an error occurs, the description from error is sent to the client. The client will show a popup and it will reset to initial screen.

IMPLEMENTATION - Client Side
For client side, a single view application was chosen. Client listens for server messages and responds to the server with other messages when is necessary(e.g.: send score);
Important Classes:
- SocketIOManager - listens for messages from server and sends notifications with message and data received.
- ViewController - user interface logic; notification handlers logic;

 


