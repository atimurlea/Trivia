/*
This class contains server errors. 
For a better management, the error code should be equal with array's index + 1
*/

function ServerError(name) {
    this.errors = [{code:1, description:"Minimum users required not fulfilled!"}];	
};

module.exports = ServerError
