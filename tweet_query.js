IP_ADDR = "10.31.212.125:8888";

var text_query = function(query) {
	
	xhr = new XMLHttpRequest();
	xhr.responseType = "json"

	request_str = "http://"+IP_ADDR + "/?text_query="+ query

	console.log('sending get request: ', request_str);
	xhr.open("GET", request_str);
	xhr.send();

	xhr.onreadystatechange = function(){
		if (xhr.readyState === 4) {
			console.log(xhr.response)
			rough = xhr.response.rough
			smooth = xhr.response.smooth
			rough_list_str = ""
			smooth_list_str = ""
			for (var i = 0; i < rough.length; i++) {
				//rough_list_str += "<li> text: " + rough[i].text + "<br />corrected: "+rough[i].corrected + "<br />fluency score: " +rough[i].confidence+"</li>"
				rough_list_str += "<li class='spaced'>" + rough[i].text + "<br /><b> Fluency Score: " + rough[i].confidence+"</b></li>"
				smooth_list_str += "<li class='spaced'>" + smooth[i].text + "<br /><b>Fluency Score: " +smooth[i].confidence+"</b></li>"
			}

			document.getElementById('rough').innerHTML = rough_list_str
			document.getElementById('smooth').innerHTML = smooth_list_str
		}
	}
}

var tweet_query = function() {
	document.getElementById('rough').innerHTML = ""
	document.getElementById('smooth').innerHTML = ""
	document.getElementById('relevant_tweets').innerHTML = ""
	document.getElementById('concepts').innerHTML = ""

	xhr = new XMLHttpRequest();
	xhr.responseType = "json"

	query = document.getElementById('query-box').value
	request_str = "http://"+IP_ADDR + "/?tweet_query="+ query

	console.log('sending get request: ', request_str);
	xhr.open("GET", request_str);
	xhr.send(); 

	xhr.onreadystatechange = function(){
		if (xhr.readyState === 4) {
			console.log(xhr.response)
			relevant_tweets = xhr.response.relevant_tweets
			concepts = xhr.response.concepts
			tweet_list_str = ""
			for (var i = 0; i < relevant_tweets.length; i++) {
				tweet_list_str += "<li><i>" + relevant_tweets[i].text + "</i> ~ <b>@"+relevant_tweets[i].user +"</b></li>"
			}
			concept_list_str = ""
			for (var i = 0; i < concepts.length; i++) {
				//concept_list_str += "<li>" + concepts[i].text + ": "+concepts[i].relevance + "</li>"
				concept_list_str += "<li>" + concepts[i].text + "</li>"

			}
			document.getElementById('relevant_tweets').innerHTML = tweet_list_str
			document.getElementById('concepts').innerHTML = concept_list_str
			text_query(query);
		}
	}
}
