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

	var enemies:FlxTypedGroup<Mobile>;
	var buttons:FlxTypedGroup<FlxSprite>;
  
  var registered:Bool = false;
  var client:mphx.client.Client;
  // var client_id:Int;
  var connection_attempts:Int = 0;

  var map:TiledMap;
  var walls:FlxTilemap;

  var ship:FlxNestedSprite;

  var controls:FlxTypedGroup<Hitbox>;

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

	  controls = new FlxTypedGroup<Hitbox>();
	  mobiles = new FlxTypedGroup<Mobile>();

		map = new TiledMap(AssetPaths.main__tmx);

		// handle tile image borders/spacing

		var stars = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 100);
		stars.scrollFactor.set(0);
	    add(stars);

		// var title = new FlxText(0, 0, 0, "maeve.", 64);
		// title.screenCenter();
		// add(title);

		var ground = new FlxTilemap();
		ground.loadMapFromArray( cast( map.getLayer("Ground"), TiledTileLayer ).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		// ground.screenCenter();
		add(ground);

    var objects = cast(map.getLayer("Objects"), TiledObjectLayer).objects;
    for (i in 0...objects.length) {
    	if (objects[i].name == "Door") {
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
	    		add(hitbox);
	    		controls.add(hitbox);
    		}
    	}
    }

		walls = new FlxTilemap();
		walls.loadMapFromArray( cast( map.getLayer("Solids"), TiledTileLayer ).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		// walls.screenCenter();
		add(walls);

		player = new Mobile(240, 260, AssetPaths.robot__png);
		player.move('idle');
		player.setHitBox();
		FlxG.camera.follow(player);
		add(player);
		mobiles.add(player);

		enemies = new FlxTypedGroup();
		add(enemies);

		// var button = new FlxSprite(160, 160);
		// button.loadGraphic(AssetPaths.button__png, true, 16, 16);
		// button.animation.add("off", [0]);
		// button.animation.add("on", [1]);
		// button.animation.play("off");
		// buttons.add(button);

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

    // client.events.on( "Leave", function (data) {
    // 	trace('leave');
    // 	for (e in enemies) {
    // 		if (e.client_id == data.client_id) {
    // 			enemies.remove(e);
    // 		}
    // 	}
    // });

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

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		client.update();

		// walls.x = ship.x - walls.width / 2;
		// walls.y = ship.y - walls.height / 2;
		player.velocity.set(0, 0);
		player.needs_updating = false;

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
		if (FlxG.keys.pressed.SPACE) {
			// registered = true;
			// trace('what is happening', player.data());
		} 
		#end

		#if (mobile || web)
		for (touch in FlxG.touches.list)
		{
		    // if (touch.justPressed) {}
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
		    // if (touch.justReleased) {}
		}
		#end

		// collisions

		// FlxG.overlap(player, buttons, function (player, button) {
		// 	button.animation.play("on");
		// });

		// FlxG.overlap(enemies, buttons, function (enemy, button) {
		// 	button.animation.play("on");
		// });

		// fix me: since collisions can happen every frame, this can ALSO get laggy
		FlxG.collide(player, enemies, function (player, enemy) {
			player.needs_updating = true;
		});

		FlxG.overlap(mobiles, controls, function (mobile, control) {
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
