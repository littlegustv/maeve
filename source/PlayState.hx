/*

multiplayer setup:
 - need EVERYONE to JOIN/REGISTER before update events start firing
 - perhaps need menustate to handle this?

*/

package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

// Tilemap stuff

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.display.FlxStarField;
import flixel.addons.display.FlxNestedSprite;

import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;

import Objects;

class PlayState extends FlxState
{
	var player:Mobile;

	var hosting:Bool = false;
	var clients:Map<String, Mobile> = new Map();
  var client:mphx.client.Client;
  var frames_since_update:Int = 0;

	var console:Console;
	var control_scheme:String = "movement";
	var shooting_angle:Float = 0;
	
	var mobiles:FlxTypedGroup<Mobile>;
	var consoles:FlxTypedGroup<Console>;
	var projectiles:FlxTypedGroup<FlxSprite>;
	var enemy_projectiles:FlxTypedGroup<FlxSprite>;
	var players:FlxTypedGroup<Mobile>;
	var lights:FlxTypedGroup<FlxSprite>;
	var enemies:FlxTypedGroup<Enemy>;
  var hitboxes:FlxTypedGroup<Hitbox>;
  
  var map:TiledMap;
  var walls:FlxTilemap;

  var back:FlxGroup;
  var front:FlxGroup;
  
  function round( n:Float, interval:Int = 1 ) {
  	return Math.round( n / interval ) * interval;
  }

  function shoot( x:Float, y:Float, angle:Float ) {
  	FlxG.sound.play( AssetPaths.shoot__wav );
  	var p = new FlxSprite( x, y, AssetPaths.projectile__png );
		p.velocity.set( 250 * Math.cos( angle ), 250 * Math.sin( angle ));
		projectiles.add(p);
  }

  function alert( color:FlxColor ) {
  	if ( color == FlxColor.RED ) {
	  	FlxG.sound.play( AssetPaths.redalert__wav );  		
  	}
  	for ( light in lights.members ) {
  		light.color = color;
  	}
  }

  function volume(to:FlxObject) {
  	return Math.max( 0.1, Math.min( 1, (FlxG.width - to.getPosition().distanceTo( player.getPosition() )) / FlxG.width ));
  }

  function create_enemy( i:Int, percent:Float = 0 ) {
  	var e = new Enemy(32 - i * 32, -128 + i  * 32, AssetPaths.enemy__png);
  	// right now loop index is used for spawn location, and for passing to other clients
  	e.index = i;
  	e.angle = 90;
  	e.tween = FlxTween.tween(e, {x: e.x + 256}, 3, { 
  		startDelay: -1 * i * 0.5,
  		type: FlxTweenType.PINGPONG,
  		ease: FlxEase.cubeInOut,
  		onComplete: function ( tween:FlxTween ) {
  			var p = new FlxSprite( e.x, e.y, AssetPaths.projectile__png );
  			p.angle = 90;
  			p.velocity.set( 0, 200 );
  			enemy_projectiles.add( p );
  			front.add( p );
  			FlxG.sound.play( AssetPaths.shoot__wav, volume(p) );
			}
		});
  	enemies.add(e);
  	front.add(e);
  	if ( percent != 0 ) {
  		e.tween.percent = percent;
  	}
  	return e;
	}

	function do_movement_controls ( elapsed:Float ) {
	 	#if (desktop || web)
			if ( FlxG.keys.pressed.UP || FlxG.keys.pressed.W ) {
				player.move('up');
			} else if ( FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S ) {
				player.move('down');
			} else if ( FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D ) {
				player.move('right');
			} else if ( FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A ) {
				player.move('left');
			} else {
				player.move('idle');
			}

			if ( FlxG.keys.justPressed.ONE ) {
		  	client.send( "Alert", { client_id: player.client_id, color: FlxColor.BLUE } );
			} else if ( FlxG.keys.justPressed.TWO ) {
		  	client.send( "Alert", { client_id: player.client_id, color: FlxColor.YELLOW } );
			} else if ( FlxG.keys.justPressed.THREE ) {
		  	client.send( "Alert", { client_id: player.client_id, color: FlxColor.RED } );
			}

			if ( FlxG.keys.justPressed.F ) {
				FlxG.overlap( player, consoles, function ( player, console:Console ) {
					if ( console.user == null ) {
						control_scheme = "weapons";
						this.console = console;
						this.console.user = player;						
						shooting_angle = FlxAngle.TO_RAD * console.weapon.angle;
						player.setPosition( 
							2 + round( console.x - 16 * Math.cos( FlxAngle.TO_RAD * console.angle), 16 ), 
							2 + round( console.y - 16 * Math.sin( FlxAngle.TO_RAD * console.angle), 16 ));
						FlxTween.tween( FlxG.camera.targetOffset, { 
							x: Math.cos( FlxAngle.TO_RAD * console.angle ) * FlxG.width / 2, 
							y: Math.sin( FlxAngle.TO_RAD * console.angle ) * FlxG.width / 2 }, 
							0.25, { onComplete: function (tween:FlxTween) {
							}
						});
						FlxTween.tween( FlxG.camera, { zoom: 0.5 }, 0.25);
						player.move('idle');
						var d:Dynamic = player.data();
						d.console_uid = console.uid;
						client.send("Station", d);
					} else {
						// FIX ME: in-game in use message / sound
					}
				});
			}
		#end
	}

	function do_weapons_controls ( elapsed:Float ) {
		#if (desktop || web)
			if ( FlxG.keys.justPressed.F ) {
				control_scheme = "movement";
				var d:Dynamic = player.data();
				d.console_uid = console.uid;
				console.user = null;
				client.send("UnStation", d);
				FlxTween.tween( FlxG.camera.targetOffset, { 
					x: 0, 
					y: 0 },
					0.25, { onComplete: function (tween:FlxTween) {
					}
				});
				FlxTween.tween( FlxG.camera, { zoom: 1 },  0.25 );
			}

			if ( FlxG.keys.pressed.RIGHT ) {
				shooting_angle = Math.max( shooting_angle - elapsed * 3, FlxAngle.TO_RAD * ( console.angle - 60 ) );
			} else if ( FlxG.keys.pressed.LEFT ) {
				shooting_angle = Math.min( shooting_angle + elapsed * 3, FlxAngle.TO_RAD * ( console.angle + 60 ) );
			}

			console.weapon.angle = FlxAngle.TO_DEG * shooting_angle;

			if ( FlxG.keys.justPressed.SPACE ) {
				shoot( console.weapon.x + console.weapon.origin.x - 2, console.weapon.y + console.weapon.origin.y - 2, shooting_angle );
				client.send("Shoot", { client_id: player.client_id, x: console.weapon.x + console.weapon.origin.x - 2, y: console.weapon.y + console.weapon.origin.y - 2, angle: shooting_angle });
			}

		#end
	}

	/*
		Eventually, this should load spawning patterns from somewhere, and have lots of variety, etc.  Right now it doesn't.
	 */

	function spawn_wave () {
	  if (this.hosting) {	  	
		  for (i in 0...4) {
		  	var e = create_enemy( i );
		  	client.send("CreateEnemy", { client_id: player.client_id, i: i, percent: e.tween.percent });
		  }
	  }
	}

	function load_objects( map:TiledMap ) {
		var objects = cast(map.getLayer("Objects"), TiledObjectLayer).objects;
    for (i in 0...objects.length) {
    	if ( objects[i].type == "Light" ) {
    		var l = new FlxSprite( objects[i].x - 8, objects[i].y - 8 );
    		l.loadGraphic( AssetPaths.light__png, true, 32, 32 );
    		l.animation.add( "main", [0, 1, 2], 5, true );
    		l.animation.play( "main" );
    		l.color = FlxColor.BLUE;
    		front.add(l);
    		lights.add(l);
    	} else if ( objects[i].type == "Door" ) {
    		for (j in [-1, 1]) {
	    		var theta = Std.parseInt(objects[i].properties.angle);
	    		var offsetx = objects[i].x + 16 * Math.cos(FlxAngle.TO_RAD * theta) * j - 16;
	    		var offsety = objects[i].y + 16 * Math.sin(FlxAngle.TO_RAD * theta) * j - 8;
	    		var door = new FlxSprite(offsetx, offsety, AssetPaths.door__png);
	    		door.angle = theta;
	    		add(door);
	    		// FIX ME: I've added two overlapping hitboxes, one for each side of the door - is there a better way?
	    		var hitbox = new Hitbox(objects[i].x - 16, objects[i].y - 16, 32, 32);
	    		hitbox.callback = function () {
	    			FlxTween.tween(door, {
	    				x: offsetx + j * 24 * Math.cos(door.angle * FlxAngle.TO_RAD),
	    				y: offsety + j * 24 * Math.sin(door.angle * FlxAngle.TO_RAD) },
	    				0.5, { type: FlxTweenType.ONESHOT }
	    			);
	    			if (j == 1) {
	    				FlxG.sound.play(AssetPaths.door__wav, volume(hitbox));
	    			}
	    		};
	    		hitbox.restore = function () {
	    			FlxTween.tween(door, { x: offsetx, y: offsety }, 0.5, { type: FlxTweenType.ONESHOT });
	    			if (j == 1) {
	    				FlxG.sound.play(AssetPaths.door__wav, volume(hitbox));
	    			}
	    		};
	    		back.add(hitbox);
	    		hitboxes.add(hitbox);
    		}
    	} else if ( objects[i].type == "Console" ) {
    		if ( objects[i].name == "Weapons" ) {
    			var console = new Console( objects[i].x - 4, objects[i].y - 4, AssetPaths.console__png );
    			console.uid = objects[i].type + i;
    			console.angle = Std.parseInt( objects[i].properties.angle );
    			consoles.add( console );
    			front.add( console );

    			var turret = new FlxSprite( objects[i].x + 32 * Math.cos( FlxAngle.TO_RAD * console.angle ), objects[i].y + 32 * Math.sin( FlxAngle.TO_RAD * console.angle ), AssetPaths.turret__png );
    			turret.angle = console.angle;
    			front.add(turret);

    			console.weapon = turret;
    		}
    	}
    }
	}

  public function new(client:mphx.client.Client, hosting:Bool = false) {
  	super();
  	this.client = client;
  	this.hosting = hosting;
  }

	override public function create():Void
	{
		super.create();

		/*
			autoPause keeps a client from pausing on unfocus (which stops it communication to server)
			worldBounds is the range in which collisions are detected
		 */

		FlxG.autoPause = false;
		FlxG.worldBounds.set(-1000, -1000, 3000, 3000);
		// FlxG.sound.playMusic(AssetPaths.ambient__wav);

		/*
			These groups are used mainly for collisions
		 */

	  hitboxes = new FlxTypedGroup<Hitbox>();
	  mobiles = new FlxTypedGroup<Mobile>();
	  consoles = new FlxTypedGroup<Console>();
	  projectiles = new FlxTypedGroup<FlxSprite>();
	  enemy_projectiles = new FlxTypedGroup<FlxSprite>();
	  enemies = new FlxTypedGroup<Enemy>();
	  lights = new FlxTypedGroup<FlxSprite>();

	  /*
	  	These are the groups used to ORDER and DRAW sprites
	   */

	  back = new FlxGroup();
	  front = new FlxGroup();

		map = new TiledMap(AssetPaths.main__tmx);

		var stars = new FlxStarField2D(-2 * FlxG.width, -2 * FlxG.height, 4 * FlxG.width, 4 * FlxG.height, 100);
		stars.scrollFactor.set(0);
    add(stars);

		var wings = new FlxTilemap();
		wings.loadMapFromArray( cast( map.getLayer("Wings"), TiledTileLayer ).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		add(wings);

		var details = new FlxTilemap();
		details.loadMapFromArray( cast( map.getLayer("Details"), TiledTileLayer ).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		add(details);

		var ground = new FlxTilemap();
		ground.loadMapFromArray( cast( map.getLayer("Ground"), TiledTileLayer ).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		add(ground);

		add(back);

    load_objects( map );

		walls = new FlxTilemap();
		walls.loadMapFromArray( cast( map.getLayer("Solids"), TiledTileLayer ).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		add(walls);

		player = new Mobile(176 + FlxG.random.int( -4, 4), 256 + FlxG.random.int( -4, 4), AssetPaths.robot__png);
		player.move('idle');
		player.setHitBox();

		add(player);
		mobiles.add(player);

		FlxG.camera.follow(player);

		players = new FlxTypedGroup();
		add(players);
    
    add(projectiles);
		add(front);

		spawn_wave();

		/*
			FIX ME: add playername ... somewhere
		 */

    client.send("RegisterNewClient", {});

    /*
    	Linkdead!
    	FIX ME: different behavior is HOSTING
     */

    client.events.on( "Leave", function ( data ) {
    	trace("[ CLIENT ] Player disconnected. ", data.client_id );
    	var p = clients.get( data.client_id );
    	clients.remove( data.client_id );
    	players.remove( p );
    });

    /*
    	Two-step join process.  
    		- First the client is REGISTERED with a unique ID
    		- Then they can JOIN the server as a player
     */

    client.events.on("RegisterSuccessful", function (data) {
    	trace("[ CLIENT ] Registered", data.client_id);
    	player.client_id = data.client_id;
	  	client.send("Join", {client_id: player.client_id, x: player.x, y: player.y});
    });

    client.events.on("Join", function (data) {
    	if (player.client_id != data.client_id) {
				var m = new Mobile(data.x, data.y, AssetPaths.robot__png);				
				m.setHitBox();
				m.client_id = data.client_id;
				clients.set(m.client_id, m);
				players.add(m);
				mobiles.add(m);
				client.send( "PlayerData", player.data() );
			  for (e in enemies) {
			  	client.send("CreateEnemy", { client_id: player.client_id, i: e.index, percent: e.tween.percent });
			  }
	    	trace('[ CLIENT ] New player joined');
    	} else {
    		trace('[ CLIENT ] Self-join event');
    	}
    });

    client.events.on( "PlayerUpdate", function (data) {
    	if (data.client_id != player.client_id) {
	    	var p = clients.get(data.client_id);
	    	if (p != null) {
	    		// trace('[ CLIENT ] Received player update');
	    		p.sync(data);
	    	} else {
	    		var m = new Mobile(data.x, data.y, AssetPaths.robot__png);
	    		m.setHitBox();
					m.client_id = data.client_id;
					clients.set(m.client_id, m);
					players.add(m);
					mobiles.add(m);
					trace('[ CLIENT ] New player created during SYNC (should not occur ?)');   
	    	}
    	}
    });

    client.events.on( "Shoot", function ( data ) {
    	if ( data.client_id != player.client_id ) {
    		trace( '[ CLIENT ] Created (friendly) projectile' );
    		shoot( data.x, data.y, data.angle );
    	}
    });

    client.events.on( "CreateEnemy", function ( data ) {
    	if ( data.client_id != player.client_id ) {
    		trace( '[ CLIENT ] Created enemy' );
    		create_enemy( data.i, data.percent );
    	}
    });

    // note: different approach used here: command goes THROUGh the server before it even gets runs by the sender
    client.events.on( "Alert", function ( data ) {
    	trace( '[ CLIENT ] Alert status changed' );
  		alert( data.color );
    });

    client.events.on( "Station", function ( data:Dynamic ) {
    	if ( data.client_id != player.client_id ) {
    		if ( clients.exists( data.client_id ) ) {
    			var p = clients.get( data.client_id );
    			p.sync( data );
    			for (c in consoles.members) {
    				if ( c.uid == data.console_uid ) {
		    			trace( '[ CLIENT ] Another crewmember is operating a station' );
    					c.user = p;
    					break;
    				}
    			}
    		}
    	}
    });

    client.events.on( "UnStation", function ( data:Dynamic ) {
    	if ( data.client_id != player.client_id ) {
  			for (c in consoles.members) {
  				if ( c.uid == data.console_uid ) {
		    		trace( '[ CLIENT ] Another crewmember stopped operating a station' );
  					c.user = null;
  					break;
  				}
  			}
  		}
    });

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		client.update();

		player.velocity.set(0, 0);

		if ( control_scheme == "movement" ) {
			
			do_movement_controls( elapsed );

		} else if ( control_scheme == "weapons" ) {
			
			do_weapons_controls( elapsed );

		}

		FlxG.collide( player, players, function ( player, enemy ) {
			player.needs_updating = true;
		});

		FlxG.overlap( mobiles, hitboxes, function ( mobile, control ) {
			control.handleOverlap();
		});

		FlxG.collide( player, walls, function ( player, wall ) {
			player.needs_updating = true;
		});
		FlxG.collide(players, walls);

		FlxG.overlap( projectiles, enemies, function ( projectile, enemy:Enemy ) {
			projectile.destroy();
			enemy.tween.cancel();
			enemies.remove( enemy, true );
			enemy.destroy();
		});

		// fix me: look into this: https://github.com/HaxeFlixel/flixel-demos/blob/master/Features/SetTileProperties/source/PlayState.hx
		//  ( as preferred way of handling this? )
		// eventually: maybe a 'damage' tilemap on top, so each tile has multiple stages of damage?
		FlxG.collide( walls, enemy_projectiles, function ( tilemap, projectile ) {
			var x = Math.round(( projectile.x - walls.x ) / 16 );
			var y = Math.round(( projectile.y - walls.y ) / 16 );
			walls.setTile(x, y, 0);
			projectile.kill();
		});

		/*
			We only update AT MOST every other frame.  Seems fine for connectivitiy, and is WAY easier on the server.
		 */

		if ( player != null && player.client_id != null && player.needs_updating == true ) {
			if ( frames_since_update <= 0) {
				frames_since_update += 1;
			} else {
				client.send("PlayerData", player.data());
				player.needs_updating = false;
			}
		}

		/*
			enemy waves, simple for now
		 */ 

		if ( enemies.length <= 0 ) {
			FlxG.sound.play( AssetPaths.wave__wav );
			spawn_wave();
		}

	}
}
