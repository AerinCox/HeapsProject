package networking;

import js.html.WebSocket;

class Client {
	var client:WebSocket;

	public function new() {
		client = new WebSocket('ws://localhost:8080');
		client.addEventListener('open', function(event) {
			client.send('Hello Server!');
		});
		client.addEventListener('message', function(event) {
			trace('Message from server: ', event.data);
		});
	}

	public function send(message:String){
		client.send(message);
	}
}
