/*
This class is the database for server.
It contains an array with objects. Each object contains one id, a name and a year
for each movie from db.txt stored on the server.
*/

function Database() {
  	this.movies = [];
	var thisClass = this;
	var fs = require('fs'),
    readline = require('readline');

	var rd = readline.createInterface({
		input: fs.createReadStream('./db.txt'),
    	output: process.stdout,
    	terminal: false
	});

	rd.on('line', function(line) {
		var lineArray = line.split(",");
    	var obj = {id:lineArray[0], name:lineArray[1], year:lineArray[2]};
		
		thisClass.movies.push(obj);
	});
};

Database.prototype.getRandomMovie = function getRandomMovie() {
	
	var index = getRandomArbitrary(0, this.movies.length-1);
	return this.movies[index];
};

function getRandomArbitrary(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
};

module.exports = Database;
