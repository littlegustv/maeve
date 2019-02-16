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

// Tilemap stuff

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.display.FlxStarField;
import flixel.addons.display.FlxNestedSprite;

import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;

import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;

import Objects;

class PlayState extends FlxState
{
	var player:Mobile;
	var players:Map<String, Mobile> = new Map();

	var mobiles:FlxTypedGroup<Mobile>;

	var console:FlxSprite;
	var consoles:FlxTypedGroup<FlxSprite>;
	var control_scheme:String = "movement";
	var shooting_angle:Float = 0;

	var projectiles:FlxTypedGroup<FlxSprite>;
	var enemies:FlxTypedGroup<Mobile>;
	var buttons:FlxTypedGroup<FlxSprite>;
  
  var registered:Bool = false;
  var client:mphx.client.Client;
  // var client_id:Int;
  var connection_attempts:Int = 0;

  var map:TiledMap;
  var walls:FlxTilemap;

  var back:FlxGroup;
  var front:FlxGroup;

  var ship:FlxNestedSprite;

  // fix me: rename as 'hitboxes' ?
  var hitboxes:FlxTypedGroup<Hitbox>;

  function shoot(x:Float, y:Float, angle:Float) {
  	FlxG.sound.play( AssetPaths.shoot__wav );
  	var p = new FlxSprite( x, y, AssetPaths.projectile__png );
		p.velocity.set( 100 * Math.cos( angle ), 100 * Math.sin( angle ));
		projectiles.add(p);
  }

  function volume(to:FlxObject) {
  	return Math.max( 0, Math.min( 1, (160 - to.getPosition().distanceTo( player.getPosition() )) / 160 ));
  }

  public function new(client:mphx.client.Client) {
  	super();
  	this.client = client;
  }

	override public function create():Void
	{
		super.create();
		FlxG.autoPause = false;
		FlxG.worldBounds.set(-1000, -1000, 3000, 3000);

		FlxG.sound.playMusic(AssetPaths.ambient__wav);

	  hitboxes = new FlxTypedGroup<Hitbox>();
	  mobiles = new FlxTypedGroup<Mobile>();
	  consoles = new FlxTypedGroup<FlxSprite>();
	  projectiles = new FlxTypedGroup<FlxSprite>();
	  back = new FlxGroup();
	  front = new FlxGroup();

		map = new TiledMap(AssetPaths.main__tmx);

		// handle tile image borders/spacing

		var stars = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 100);
		stars.scrollFactor.set(0);
    add(stars);

    add(projectiles);

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

    var objects = cast(map.getLayer("Objects"), TiledObjectLayer).objects;
    for (i in 0...objects.length) {
    	if ( objects[i].type == "Door" ) {
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
	    				// trace('playing sound!');
		    			FlxG.sound.play(AssetPaths.door__wav, volume(hitbox));
	    			}
	    		};
	    		hitbox.restore = function () {
	    			FlxTween.tween(door, { x: offsetx, y: offsety }, 0.5, { type: FlxTweenType.ONESHOT });
	    			if (j == 1) {
	    				// trace('playing sound!');
		    			FlxG.sound.play(AssetPaths.door__wav, volume(hitbox));
	    			}
	    		};
	    		back.add(hitbox);
	    		hitboxes.add(hitbox);
    		}
    	} else if ( objects[i].type == "Console" ) {
    		if ( objects[i].name == "Weapons" ) {
    			var console = new FlxSprite( objects[i].x - 4, objects[i].y - 4, AssetPaths.console__png );
    			console.angle = Std.parseInt( objects[i].properties.angle );
    			consoles.add( console );
    			front.add( console );
    		}
    	}
    }

		walls = new FlxTilemap();
		walls.loadMapFromArray( cast( map.getLayer("Solids"), TiledTileLayer ).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		add(walls);

		add(front);

		player = new Mobile(240, 260, AssetPaths.robot__png);
		player.move('idle');
		player.setHitBox();
		// FlxG.camera.setSize(2 * FlxG.width, 2 * FlxG.width);
		FlxG.camera.follow(player);
		add(player);
		mobiles.add(player);

		enemies = new FlxTypedGroup();
		add(enemies);

    client.send("ClientRegister", "HELLO!!!");


    client.events.on("ServerRegister", function (data) {
    	trace("CLIENT: Registered", data.client_id);
    	player.client_id = data.client_id;
    	// registered = true;
	  	client.send("Join", {client_id: player.client_id, x: player.x, y: player.y});
    });

    client.events.on("Join", function (data) {
    	trace('join');
    	if (player.client_id != data.client_id) {
				var m = new Mobile(data.x, data.y, AssetPaths.robot__png);				
				m.setHitBox();
				m.client_id = data.client_id;
				players.set(m.client_id, m);
				enemies.add(m);
				mobiles.add(m);
				trace('new');   		
    	}
    });

    client.events.on( "PlayerUpdate", function (data) {
    	// trace('player_update', data.client_id, player.client_id);
    	if (data.client_id != player.client_id) {
	    	var p = players.get(data.client_id);
	    	if (p != null) {
	    		p.sync(data);
	    	} else {
	    		var m = new Mobile(data.x, data.y, AssetPaths.robot__png);
	    		m.setHitBox();
					m.client_id = data.client_id;
					players.set(m.client_id, m);
					enemies.add(m);
					mobiles.add(m);
					trace('new (during sync)');   
	    	}
    	}
    });

    client.events.on( "Shoot", function ( data ) {
    	if ( data.client_id != player.client_id ) {
    		shoot( data.x, data.y, data.angle );
    	}
    });

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		client.update();

		player.velocity.set(0, 0);
		player.needs_updating = false;

		if ( control_scheme == "movement" ) {
			#if (desktop || web)
				if (FlxG.keys.pressed.UP) {
					player.move('up');
				} else if (FlxG.keys.pressed.DOWN) {
					player.move('down');
				} else if (FlxG.keys.pressed.RIGHT) {
					player.move('right');
				} else if (FlxG.keys.pressed.LEFT) {
					player.move('left');
				} else {
					player.move('idle');
				}

				if ( FlxG.keys.justPressed.F ) {
					FlxG.overlap( player, consoles, function ( player, console ) {
						control_scheme = "weapons";
						this.console = console;
						shooting_angle = FlxAngle.TO_RAD * console.angle;
						player.setPosition( console.origin.x + console.x - 16 * Math.cos( FlxAngle.TO_RAD * console.angle), console.origin.y + console.y - 16 * Math.sin( FlxAngle.TO_RAD * console.angle) );
						FlxTween.tween( FlxG.camera.targetOffset, { 
							x: Math.cos( FlxAngle.TO_RAD * console.angle ) * FlxG.width / 3, 
							y: Math.sin( FlxAngle.TO_RAD * console.angle ) * FlxG.width / 3 }, 
							0.25, { onComplete: function (tween:FlxTween) {
							}
						});
						// FlxTween.tween( FlxG.camera, { zoom: 0.5 },  0.25 );
						player.move('idle');
					});
				}
			#elseif (mobile || web)
				for (touch in FlxG.touches.list)
				{
				    if (touch.pressed) {
				    	if (touch.screenY > 2 * FlxG.height / 3) {
				    		player.move("down");
				    	} else if (touch.screenY < FlxG.height / 3) {
				    		player.move("up");
				    	} else if (touch.screenX > 2 * FlxG.width / 3) {
				    		player.move("right");
				    	} else if (touch.screenX < FlxG.width / 3) {
				    		player.move("left");
				    	} else {
				    		registered = true;
				    	}
				    }
				}
			#end
		} else if ( control_scheme == "weapons" ) {
			#if (desktop || web)
				if ( FlxG.keys.justPressed.F ) {
					control_scheme = "movement";
					FlxTween.tween( FlxG.camera.targetOffset, { 
						x: 0, 
						y: 0 },
						0.25, { onComplete: function (tween:FlxTween) {
							trace('done camering', FlxG.camera.x, FlxG.camera.y);
						}
					});
					// FlxTween.tween( FlxG.camera, { zoom: 1 },  0.25 );
				}

				if ( FlxG.keys.pressed.RIGHT ) {
					shooting_angle -= elapsed * 1;
				} else if ( FlxG.keys.pressed.LEFT ) {
					shooting_angle += elapsed * 1;
				}

				if ( FlxG.keys.justPressed.SPACE ) {
					shoot(console.x, console.y, shooting_angle);
					client.send("Shoot", { client_id: player.client_id, x: console.x, y: console.y, angle: shooting_angle });
				}

				// fix me: visible aiming of some kind
			#end
		}

		// fix me: since collisions can happen every frame, this can ALSO get laggy
		FlxG.collide(player, enemies, function (player, enemy) {
			player.needs_updating = true;
		});

		FlxG.overlap(mobiles, hitboxes, function (mobile, control) {
			control.handleOverlap();
		});

		FlxG.collide(player, walls, function (player, wall) {
			player.needs_updating = true;
		});

		if ( player != null && player.client_id != null && player.needs_updating == true ) {
			client.send("PlayerData", player.data());
		}
	}
}
