// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket, Presence} from "phoenix"

var user_id = $("#player_id")[0].innerHTML
let socket = new Socket("/socket", {params: {user_id: user_id}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})
window.channel = channel

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

function user_row_template(profile_picture_url, username, id, position_x) {
  return `
  <li class="mt-2 d-flex align-items-start livechat-row">
      <div class="mr-3">
        <img src="${profile_picture_url}"/>
      </div>
      <div>
        <div class="d-flex aligns-items-end">
            <h5 class="mr-3 mb-1">
              ${username}
            </h5>
        </div>
        <div class="body">
            <p>Online</p>
	    <p id="player_${id}_position_x">${position_x}</p>
        </div>
      </div>
  </li>
  `
}

// PResence
function render_users(presence_list){
	$("#users-data").empty()
	var online_players_id = presence_list.map((x) => (x.metas[0].user_id))
	// NOT WORKING: for some reason remove immediately players that should not be removed
	// and prevent other users to be shown
	//window.game.removeOfflinePlayers(online_players_id)
	presence_list.forEach((presence) => {
		// add to lhc list
		var presence_data = presence.metas[0]
		$("#users-data").append(
			user_row_template(
				presence_data.profile_picture_url, 
				presence_data.username,
				presence_data.user_id,
				presence_data.position.x
			))
		// add to game
		if( presence_data.user_id != user_id ){
			window.game.addOnlinePlayer(presence_data.user_id, presence_data.username, presence_data.position)
		}
	})
}
let presence = new Presence(channel)

// detect if user has joined for the 1st time or from another tab/device
presence.onJoin((id, current, newPres) => {
  if(!current){
    console.log("user has entered for the first time", newPres)
  } else {
    console.log("user additional presence", newPres)
  }
})

// detect if user has left from all tabs/devices, or is still present
presence.onLeave((id, current, leftPres) => {
  if(current.metas.length === 0){
    console.log("user has left from all devices", leftPres)
  } else {
    console.log("user left from a device", leftPres)
  }
})

// receive presence data from server
presence.onSync(() => {
  render_users(presence.list())
})
window.presence = presence

export default socket
