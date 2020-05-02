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
console.log(channel)

channel.on('shout', function (payload) {
	let li = document.createElement("li");
	li.innerHTML = '<b>' + payload.name + "</b> : " + payload.message;
	ul.appendChild(li);
});

channel.join();
console.log(channel)

let ul = document.getElementById('msg-list');
let name = document.getElementById('name');
let msg = document.getElementById('msg');
let send_button = document.getElementById('send');

send_button.addEventListener('click', function (event) {
	channel.push('shout', {
		name: name.value,
		message: msg.value
	});
});
