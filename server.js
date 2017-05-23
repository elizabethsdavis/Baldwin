var cluster = require('cluster');

// Master Process
if(cluster.isMaster) {
	var numWorkers = require('os').cpus().length;

	console.log('Master cluster setting up ' + numWorkers + ' api workers...');

	// setup as many worker (server) processes as cpu cores
	// working in tandem on the same port
	for(var i = 0; i < numWorkers; i++) {
        cluster.fork();
    }

    // let us know all is well 👍🏾
    cluster.on('online', function(worker) {
        console.log('Worker ' + worker.process.pid + ' is online');
    });

    // setup a new worker on worker failure
    cluster.on('exit', function(worker, code, signal) {
        console.log('Worker ' + worker.process.pid + ' died with code: ' + code + ', and signal: ' + signal);
        console.log('Starting a new worker');
        cluster.fork();
    });


// Worker Processes
} else {

	const express        = require('express');
	const MongoClient    = require('mongodb').MongoClient;
	const bodyParser     = require('body-parser');
	const app            = express();
	const sys 			 = require('util');
	const exec 			 = require('child_process').exec;

	const port = process.env.PORT || 8000; // PORT supplied by Heroku dyno
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
		console.log('Worker-' + process.pid + ': Receiving a message from a Baldwin client');

		// TODO: process the request msg with Baldwin, get a response msg

		// Sample response. 
		// This should come from the Baldwin Ai backend for end-to-end integration.

		messages = [

			"Hey! I'm Baldwin ✊🏾", 
			"Yo!", 
			"Sorry, I don't understand that yet. #justwaitonit", 
			"Hm. Wonder what you just said 🤔", 
			"Hope your day is well.", 
			"👐🏾",
			"Hey, what's up, hello!"
		];

		var message = messages[Math.floor(Math.random() * messages.length)]; // random message

		response.contentType('application/json');
		var BaldwinUtterance = { 
			"message": message,
			"misc": "This is some fake text representing additional info." 
		};
		var json = JSON.stringify(BaldwinUtterance);
		response.send(json);
	}


	// MARK: - Express API
	app.get('/', function(request, response){

		var data = response.data;
		
		var child;

		console.log('running program...');
		child = exec('cd ../practice && python e2e.py --query "black lives matter"',
			function (error, stdout, stderr) {
				if (stderr !== null) {
					console.log('stderr: ' + stderr);
					response.status(400).send(stderr);
				}
				console.log('stdout: ' + stdout);
				if (error !== null) {
					console.log('exec error: ' + error);
					response.status(400).send(error);
				}
				var result = JSON.parse(stdout);
				console.log(result);
				response.send(result["text"]);
			});
		// response.send("Hey World!");

	});

	app.get('/chat', handleChatMessage);


	app.listen(port, function () {
	  console.log('We (worker ' + process.pid + ') are live on ' + port);
	});



}