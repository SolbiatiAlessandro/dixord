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
// import socket from "./socket"

import {Socket} from "phoenix"
 import LiveSocket from "phoenix_live_view"

 let Hooks = {}
// Hooks.MsgList = {
// 	updated() {
// 	console.log("msglist updated")
// 	$('#msg-list').children()[$('#msg-list').children().length - 1].scrollIntoView()
// 		}
// 		}
//
Hooks.PlayerPosition = {
  mounted(){
	var hook = this
	const player_position_observer = new MutationObserver(function(mutationsList, observer) {
	    // Use traditional 'for loops' for IE 11
	    for(let mutation of mutationsList) {
		if (mutation.type === 'attributes') {
		    var attribute = mutation.target.attributes[mutation.attributeName]
		    var value = attribute ? attribute.value : 0
		    console.log('The ' + mutation.attributeName + ' attribute was modified: ' + value );
		    //hook.pushEvent("player-position-updated", {axis: mutation.attributeName, value: value})
		}
	    }
	});
	player_position_observer.observe($("#player_position")[0], {attributes: true});
  }
}



let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks})
liveSocket.connect()
window.liveSocket = liveSocket

import Game from "./game"
document.addEventListener("DOMContentLoaded", function(){
	const game = new Game();
	window.game = game;//For debugging only
});
