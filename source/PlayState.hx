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
import flixel.group.FlxGroup;

// Tilemap stuff

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.display.FlxStarField;
import flixel.addons.display.FlxNestedSprite;

import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;

import Objects;

class PlayState extends FlxState
{
	var player:Mobile;
	var enemies:FlxTypedGroup<Mobile>;
	var buttons:FlxTypedGroup<FlxSprite>;
  
  var registered:Bool = false;
  var client:mphx.client.Client;
  // var client_id:Int;
  var connection_attempts:Int = 0;

  var map:TiledMap;
  var walls:FlxTilemap;

  var ship:FlxNestedSprite;

  public function new(client:mphx.client.Client) {
  	super();
  	this.client = client;
  }

	override public function create():Void
	{
		super.create();
		FlxG.autoPause = false;
		FlxG.worldBounds.set(-1000, -1000, 3000, 3000);

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
		ground.screenCenter();
		add(ground);

		walls = new FlxTilemap();
		walls.loadMapFromArray( cast( map.getLayer("Solids"), TiledTileLayer ).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		walls.screenCenter();
		add(walls);

		buttons = new FlxTypedGroup();
		add(buttons);

		// ship = new FlxNestedSprite(0, 0);
		// ship.velocity.set(40, 0);
		// add(ship);
		
		player = new Mobile(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height), AssetPaths.player__png);
		player.move('idle');
		FlxG.camera.follow(player);
		add(player);

		enemies = new FlxTypedGroup();
		add(enemies);

		var button = new FlxSprite(160, 160);
		button.loadGraphic(AssetPaths.button__png, true, 16, 16);
		button.animation.add("off", [0]);
		button.animation.add("on", [1]);
		button.animation.play("off");
		buttons.add(button);

    // client = new mphx.client.Client("192.168.1.22", 8000);
    // trace(client);
    // client.onConnectionError = function (error:Dynamic) {
    //   trace("On Connection Error:", error.keys, connection_attempts);
    //   connection_attempts += 1;
    //   if (connection_attempts <= 10) {
    //     client.connect();
    //   }
    // };
    // client.onConnectionClose = function (error:Dynamic) {
    //   trace("Connection Closed:", error);
    // };
    // client.onConnectionEstablished = function () {
    //   trace('registering??');
    // };
    // client.connect();
    client.send("Register", "HELLO!!!");

    client.events.on("Registered", function (data) {
    	trace("Registered", data.id);
    	player.client_id = data.id;
    	// registered = true;
	  	client.send("Join", {client_id: player.client_id, x: player.x, y: player.y});
    });

    client.events.on("Join", function (data) {
    	trace('join');
    	if (player.client_id != data.client_id) {
				var enemy = new Mobile(data.x, data.y, AssetPaths.player__png);
				enemy.client_id = data.client_id;
				enemies.add(enemy);
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
    	if (data.client_id != player.client_id) {
	    	var found = false;
	    	for (e in enemies) {
	    		if (e.client_id == data.client_id) {
	    			e.sync(data);
	    			found = true;
	    		}
	    	}
	    	if (found == false) {
	    		var enemy = new Mobile(data.x, data.y, AssetPaths.player__png);
	    		enemy.client_id = data.client_id;
					enemies.add(enemy);
					trace('new (during sync)');   
	    	}
    	}
    });

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// walls.x = ship.x - walls.width / 2;
		// walls.y = ship.y - walls.height / 2;
		player.velocity.set(0, 0);

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
			registered = true;
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

		FlxG.overlap(player, buttons, function (player, button) {
			button.animation.play("on");
		});

		FlxG.overlap(enemies, buttons, function (enemy, button) {
			button.animation.play("on");
		});

		FlxG.collide(player, enemies, function (player, enemy) {
			trace('collided with enemy!');
		});

		FlxG.collide(player, walls);

		if ( true ) {
			client.send("PlayerData", player.data());
		}
	}
}
