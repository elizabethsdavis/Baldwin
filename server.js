// server.js
const express        = require('express');
const MongoClient    = require('mongodb').MongoClient;
const bodyParser     = require('body-parser');
const app            = express();

const port = process.env.PORT || 8000;
app.use(bodyParser.json());


// MARK: API Helpers

/* Receives a message from a client, forwards it to the Baldwin ai backend for processing, 
 * and hands the Balwin ai's response back to the client 
 *
 * Response type: JSON
 *     message - a string message
 *     misc    - potentially more information
 */
function handleChatMessage(request, response) {
	console.log('Receiving a message from a Baldwin client');

	// TODO: process the request msg with Baldwin, get a response msg

	// Sample response. 
	// This should come from the Baldwin Ai backend for end-to-end integration.
	response.contentType('application/json');
	var BaldwinUtterance = { 
		"message": "Hey! I'm Baldwin ✊🏾",
		"misc": "This is some fake text representing additional info." 
	};
	var json = JSON.stringify(BaldwinUtterance);

	response.send(json);
}



// MARK: - Express API
app.get('/', function(request, response) {
   response.send("Hello World");
   //response.render('pages/index');
});

app.get('/chat', handleChatMessage);


app.listen(port, () => {
  console.log('We are live on ' + port);
});