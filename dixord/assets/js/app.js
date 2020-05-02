// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"

let channel = socket.channel("room:lobby", {})
channel.on('shout', function (payload) {
	console.log("receiving shout ")
	let li = document.createElement("li");
	let name = payload.name || 'guest';
	li.innerHtml = '<b>' + name + '</b>';
	ul.appendChild(li);
});

channel.join();

let ul = document.getElementById('msg-list');
let name = document.getElementById('name');
let msg = document.getElementById('msg');

msg.addEventListener('keypress', function (event) {
	console.log("keypress")
	if (msg.value.lenght > 0){
		console.log("shouting ")
		console.log(msg.value)
		channel.push('shout', {
			name: name.value,
			message: msg.value
		});
		msg.value = '';
	}
});
