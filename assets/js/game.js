import Preloader from "./preloader"
import { FBXLoader } from "./vendor/FBXLoader"
import { SFX } from "./audio"
import { rotateAboutCenter } from "./geometry"

class Game{
    // preload game assets
    constructor(socket_channel){
	  const game = this;
	  this.socket_channel = socket_channel;
	  this.player = { };
	  this.modes = Object.freeze({
		NONE: Symbol("none"),
		INIT: Symbol("init"),
		ACTIVE: Symbol("active")
	  })
	  this.mode = this.modes.NONE;

	  const options = {
		assets: [],
		oncomplete: function(){
		  game.init();
		  game.animate();
		},
		  container: document.getElementById("renderer")
	  }

	  // first animation is set as soon as the character is spawned
	  this.animations = ["standing", "walking", "dancing", "sitting", "sit-look-around"]
	  this.assetsPath = 'fbx/';
	  this.animations.forEach( function(animation){ options.assets.push(
		`${game.assetsPath}${animation}.fbx`
	  )})

	  this.clock = new THREE.Clock();
	  const preloader = new Preloader(options)

	  window.onError = function(error){
	      console.error(JSON.stringify(error));
	  }

	  this.audioAssetsPath = 'sfx/';
	  this.initSfx()
	  this.mute = false
	  document.getElementById("sfx-btn").onclick = function(){ game.toggleSound(); };
    }

	// initialises the game scene, camera and objects
    init(){
	    this.FBXloader = new THREE.FBXLoader();
	  this.loadMultiplayer();

	    this.mode = this.modes.INIT;

		// scene setup, light camera and background.
        this.scene = new THREE.Scene();
	    this.scene.background = new THREE.Color( 0x2edaff  );

		// grid helper
	    var size = 1000;
		var divisions = 10;
		var gridHelper = new THREE.GridHelper( size, divisions );
		//this.scene.add( gridHelper );

        let light = new THREE.HemisphereLight( 0xffffff, 0x444444, 1 );
        light.position.set( 0, 500, 0 );
        this.scene.add( light );
 
        light = new THREE.DirectionalLight( 0xffffff, 0.1 );
        light.position.set( 0, 200, 100 );
        light.castShadow = true;
        light.shadow.mapSize.width = 2048;
        light.shadow.mapSize.height = 2048;
        light.shadow.camera.top = 3000;
        light.shadow.camera.bottom = -3000;
        light.shadow.camera.left = -3000;
        light.shadow.camera.right = 3000;
        light.shadow.camera.far = 3000;
        this.scene.add( light );

        // ground
		/*
        var mesh = new THREE.Mesh( new THREE.PlaneBufferGeometry    ( 2000, 2000 ), new THREE.MeshPhongMaterial( { color: 0x999999,     depthWrite: false } ) );
        mesh.rotation.x = - Math.PI / 2;
        //mesh.position.y = -100;
        mesh.receiveShadow = true;
        this.scene.add( mesh );
		*/

	    var light_2 = new THREE.PointLight( 0x000000, 1, 100 );
	    light_2.position.set( 50, 50, 50 );
	    this.scene.add( light_2 );

		this.camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 0.1, 10000 );
	    this.camera.position.set(112, 100, 200);
	    this.camera.quaternion.set(0.07133122876303646, -0.17495722675648318,     -0.006135162916936811, -0.9819695435118246);

		this.renderer = new THREE.WebGLRenderer();
        this.renderer.setSize( window.innerWidth, window.innerHeight );
        document.getElementById("renderer").appendChild( this.renderer.domElement );

		// model setup
	    const game = this
		// bootup model with the first animation
	    this.FBXloader.load( `${this.assetsPath}${this.animations[0]}.fbx`,
		  function (object) {
			object.mixer = new THREE.AnimationMixer( object );
			game.player.mixer = object.mixer;
			game.player.root = object.mixer.getRoot();
			const first_action = game.player.mixer.clipAction( object.animations[0] )
			first_action.play()

			object.name = "Character"
			game.player.object = object
			object.traverse( function (child){
			  if ( child.isMesh ) {
				child.castShadow = true;
				child.receiveShadow = true;
			  }
			});
			 
			game.scene.add(object)
			game.mode = game.modes.ACTIVE;
		})


		// render name on top of the model 
	    var parent = new THREE.Object3D();
	    parent.position.y = 200;

	    var text_loader = new THREE.FontLoader();
	    text_loader.load( 'fonts/helvetiker_regular.typeface.json', function ( font ) {
		    var  textGeo = new THREE.TextGeometry(game.player.username, {
			                size: 12,
			                height: 5,
			                curveSegments: 6,
			                font: font,
			        });
		        var  color = new THREE.Color();
		        color.setRGB(255, 250, 250);
		        var  textMaterial = new THREE.MeshBasicMaterial({ color: color });
		        var  text = new THREE.Mesh(textGeo , textMaterial);
		        text.position.y = 200
		    text.rotation.y = Math.PI ;
		        game.scene.add(text);
		        game.player.username_mesh = text
	    } );

	    //load remaining animation"
		this.animations.forEach(function(animation){
		  game.FBXloader.load( `${game.assetsPath}${animation}.fbx`, function(object){
			game.player[animation] = object.animations[0]
		  })
		})

	  //setup keybindings
	  game.player.move = {forward: 0, direction: 0}
	  document.addEventListener("keydown", event => {
		if (event.code === "KeyW"){
		  console.log('KeyW down')
		  this.sfx.walking.play()
		  game.player.move.forward = 1;
		  game.action = 'walking';
		}
		// Space either plays interaction or 'dancing' by default
		if (event.code === "Space"){
		  this.playing_interaction = false
		  for(var interaction_name in this.interactions){
			var interaction = this.interactions[interaction_name]
			if(interaction["triggered"]){
			  interaction.interact(interaction["object"])
			  this.playing_interaction = true
			  interaction["triggered"] = false
			}
		  }
		  if(!this.playing_interaction){
			game.action = 'dancing';
		  }
		}
		if (event.code === "KeyA") game.player.move.direction = 3;
		if (event.code === "KeyD") game.player.move.direction = -3;
	  })
	  document.addEventListener("keyup", event => {
		if (event.code === "KeyW"){
		  console.log('KeyW up')
		  game.player.move.forward = 0;
		  this.sfx.walking.stop()
		  game.action = 'standing';
		}
		if (event.code === "KeyA") game.player.move.direction = 0;
		if (event.code === "KeyD") game.player.move.direction = 0;
	  })
	  
	  // environment
	  game.loadEnvironment();

	}

    removeOfflinePlayers(online_players_id){
	if(this.online_players == undefined){
		return
	}
	Object.keys(this.online_players).forEach((id) => {
		if( !online_players_id.includes(id) ) {
			this.scene.remove(this.online_players[id].object);
		}
	})
    }

    updateOnlinePlayerPosition(player_id, axis){
	    var position_info = $(`#player_${player_id}_position_${axis}`)[0]
	    if(this.online_players[player_id] != undefined && this.online_players[player_id].object != undefined && position_info != undefined){
		    var position = parseFloat(position_info.innerHTML);
		    this.online_players[player_id].object.position[axis] = position
	    }
    }

    updateOnlinePlayerRotation(player_id, axis){
	    var rotation_info = $(`#player_${player_id}_rotation_${axis}`)[0]
	    if(this.online_players[player_id] != undefined && this.online_players[player_id].object != undefined && rotation_info != undefined){
		    var rotation = parseFloat(rotation_info.innerHTML);
		    this.online_players[player_id].object.rotation[axis] = rotation
	    }
    }

    updateOnlinePlayerAction(player_id){
	  var action_info = $(`#player_${player_id}_action`)[0]
	  if(this.online_players[player_id] != undefined && this.online_players[player_id].object != undefined && action_info != undefined){
		  var action_name = action_info.innerHTML
		  var player = this.online_players[player_id]
		  if(player.action === action_name){
			  // already playing this action
			  return
		  }
		  var animation = this.player[action_name]
		  const action = this.online_players[player_id].mixer.clipAction( animation );
		  action.time = 0
		  player.mixer.stopAllAction();
		  player.action = action_name;
		  //action.fadeIn(0.1);
		  if (action_name=='sitting') action.loop = THREE.LoopOnce;
		  //if (name=="sit-look-around") action.fadeIn(0.5)
		  action.play();
	  }
    }

    addOnlinePlayer(id, username, position){
	    console.log("adding online player");
	    if(this.online_players == undefined){
		    return
	    }
	    if(this.online_players && Object.keys(this.online_players).includes(String(id))){
		    return
	    }
	    this.online_players[id] = {id: id, username: username, position: position}

	    const game = this
	    game.FBXloader.load( `${this.assetsPath}${this.animations[0]}.fbx`,
		  function (object) {
			try{
			object.mixer = new THREE.AnimationMixer( object );
			game.online_players[id].mixer = object.mixer;
			game.online_players[id].root = object.mixer.getRoot();
			const first_action = game.online_players[id].mixer.clipAction( object.animations[0] )
			first_action.play()

			object.name = "Character" + id
			object.position.x = position.x
			object.position.y = position.y
			object.position.z = position.z
			game.online_players[id].object = object
			object.traverse( function (child){
			  if ( child.isMesh ) {
				child.castShadow = true;
				child.receiveShadow = true;
			  }
			});
			 
			game.scene.add(object)
			} catch (error) {
				;debugger
				console.log(error)
			}
		})
    }

    loadMultiplayer(){
	    this.player.username = $("#player_username")[0].innerHTML
	    this.player.id = $("#player_id")[0].innerHTML

	    this.online_players = {}
	    //this.addOnlinePlayer('-1', 'NonPlayingCharacter', {x: 300, y: 0, z: 0})

    }

    loadInteractions(){
	  this.interactions = {'OfficeChair_02': {
		interact: game.interaction_sitOnChair, 
		"object": null,
		"distance": 100,
		"triggered": false,
		"action": "sitting"
		}
	  };
	  game = this

	  for(var interaction_name in this.interactions){
		game.environmentProxy.children.forEach(function(mesh){
		  if( mesh.name === interaction_name ){
			game.interactions[interaction_name]["object"] = mesh;
		  }
		})
	  }
	}

    interaction_sitOnChair(mesh){
	  // follows example of hardcoded value for the chair of
	  // the current environment
	  game.player.object.position.x = -1 * mesh.position.x + 60
	  game.player.object.position.y = mesh.position.y
	  game.player.object.position.z = -1 * mesh.position.z
	  game.player.object.rotation.y = -4.8

	  game.action = "sitting"
	  game.player.mixer.addEventListener( 'finished', () => {
		game.action = "sit-look-around"
	  })
	}

	loadEnvironment(){
	  const game = this;
	  this.FBXloader.load( `${this.assetsPath}game_environment.fbx`, function(object){
		game.scene.add(object);
		object.receiveShadow = true;
		object.name = "Environment"
		//object.scale.set(0.6, 0.6, 0.6);
		object.rotateY( Math.PI );
		object.position.y = -20
        object.traverse( function ( child ) {
            if ( child.isMesh ) {
                    child.castShadow = true;
                    child.receiveShadow = true;
			}});
		 game.environmentProxy = object;
		 game.loadInteractions()
	  });
	}

    toggleSound(){
        this.mute = !this.mute;
        const btn = document.getElementById('sfx-btn');
        
        if (this.mute){
            for(let prop in this.sfx){
                let sfx = this.sfx[prop];
                if (sfx instanceof SFX) sfx.stop();
            }
            btn.innerHTML = 'sound OFF';
        }else{
            this.sfx.soundtrack.play();
            btn.innerHTML = 'sound ON';
        }
    }

	initSfx(){
		this.sfx = {};
		this.sfx.context = new (window.AudioContext || window.webkitAudioContext)();
		const list = ['soundtrack', 'walking' ];
		const game = this;
		list.forEach(function(item){
			game.sfx[item] = new SFX({
				context: game.sfx.context,
				src:{
				  mp3:`${game.audioAssetsPath}${item}.mp3`, 
				  wav:`${game.audioAssetsPath}${item}.wav`
				},
				loop: (true),
				autoplay: (item=='soundtrack'),
				volume: 0.3
			});	
		})
	}

    set action(name){
	  const animation = this.player[name]
	  const action = this.player.mixer.clipAction( animation );
	  action.time = 0
	  this.player.mixer.stopAllAction();
	  this.player.action = name;
	  //action.fadeIn(0.1);
	  if (name=='sitting') action.loop = THREE.LoopOnce;
	  //if (name=="sit-look-around") action.fadeIn(0.5)
	  action.play();
	}

	animate() {
        const game = this;
		const dt = this.clock.getDelta();

        requestAnimationFrame( function(){ game.animate(); } );
	   
	  // animation mixer
	    if (this.player.mixer != undefined && this.mode == this.modes.ACTIVE){
		  this.player.mixer.update(dt);
		}

	  // movements
		if (this.player.object != undefined){
		  // player object translations
		  if (this.player.move.forward > 0) this.moveForward(dt);
		  this.player.object.rotation.y +=  (this.player.move.direction * dt);
		  var player_position = this.player.object.position.clone();
		  var player_rotation = this.player.object.rotation.clone();

		  // username_mesh tracking
	          this.player.username_mesh.rotation.set(player_rotation.x, player_rotation.y + Math.PI, player_rotation.z)
	          this.player.username_mesh.position.set(player_position.x, player_position.y, player_position.z)
		  // this.player.username_mesh.position.z += 200
		  this.player.username_mesh.translateY(200)
	          this.player.username_mesh.rotateY(-player_rotation.y)
		  this.player.username_mesh.translateX(-1 * 10 * game.player.username.length / 2)
		  // this.player.username_mesh.translateZ(50)
		  

		  // camera tracking
		  var camera_position = this.player.object.position.clone();
		  var camera_distance = 500
		  var camera_angle = (Math.PI / 4) + this.player.object.rotation.x
		  camera_position.y += Math.sin(camera_angle) * (camera_distance - 150)
		  camera_position.z -= Math.cos(camera_angle) * camera_distance
		  this.camera.position.set(camera_position.x, camera_position.y, camera_position.z)
		  this.camera.lookAt(player_position);
        }

	  // interactions
	    if (this.interactions != undefined && this.player.object != undefined){
		  for(var interaction_name in this.interactions){
			var interaction = this.interactions[interaction_name];

			// for some unknown reason we need to adjust position of the mesh
			var object_adjusted_position = interaction["object"].position.clone();
			object_adjusted_position.z *= -1
			object_adjusted_position.x *= -1

			var curr_distance = this.player.object.position.distanceTo(
			  object_adjusted_position
			)
			if(curr_distance <= interaction["distance"]){
			  interaction["triggered"] = true
			  document.getElementById("message").style.display = "block"
			}
			else{
			  document.getElementById("message").style.display = "none"
			  interaction["triggered"] = false
			}
		  }
		}

	// update multiplayer objects
        for(var player_id in this.online_players){
	    var player = this.online_players[player_id]
	    if (player.mixer != undefined){
		    player.mixer.update(dt);
	    }

	    this.updateOnlinePlayerPosition(player_id, 'x')
	    this.updateOnlinePlayerPosition(player_id, 'y')
	    this.updateOnlinePlayerPosition(player_id, 'z')
	    this.updateOnlinePlayerRotation(player_id, 'x')
	    this.updateOnlinePlayerRotation(player_id, 'y')
	    this.updateOnlinePlayerRotation(player_id, 'z')
	    this.updateOnlinePlayerAction(player_id)
	}


        this.renderer.render( this.scene, this.camera );

		//after rendering broadcast data for multiplayer
		if (this.player.object != undefined){;
			['x', 'y', 'z'].forEach(function updateAxis(axis) {
				// TODO: optimse to broadcast only when value changes
				var position_axis_value = game.player.object.position[axis];
				game.socket_channel.push('player-position-updated', {
				  player_id:  game.player.id,
				  axis: axis,
				  value: position_axis_value
				});
				var rotation_axis_value = game.player.object.rotation[axis];
				game.socket_channel.push('player-rotation-updated', {
				  player_id:  game.player.id,
				  axis: axis,
				  value: rotation_axis_value
				});
				var action_value = game.player.action
				game.socket_channel.push('player-action-updated', {
				  player_id:  game.player.id,
				  value: action_value
				})
			})
		}
    }

    moveForward(dt){


	  /* raycasting (object collision) */
	  const player_position = this.player.object.position.clone();
	  let dir = this.player.object.getWorldDirection();
	  let raycaster_foot = new THREE.Raycaster(player_position, dir);
	  player_position.y += 1
	  let raycaster_head = new THREE.Raycaster(player_position, dir);
	  let blocked = false;

	  for(let box of this.environmentProxy.children){
		const intersect_foot = raycaster_foot.intersectObject(box);
		const intersect_head = raycaster_foot.intersectObject(box);
		if (intersect_foot.length > 0 && intersect_foot[0].distance < 50){
		  blocked = true;
		  break;
		}
		if (intersect_head.length > 0 && intersect_head[0].distance < 50){
		  blocked = true;
		  break;
		}
	  }

	  if (blocked) return;

	  /* move on the surface of the cylinder */
	  var rotation = Math.cos(this.player.object.rotation.y)
	  var translation = Math.sin(this.player.object.rotation.y)
	  rotateAboutCenter(
		this.player.object,
		new THREE.Vector3(this.player.object.position.x, -2000, 0),
		THREE.Math.degToRad(5*dt*rotation)
	  );
	  this.player.object.position.x += (dt*150*translation);
	}
}

export default Game
