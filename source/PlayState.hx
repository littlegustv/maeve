/*

multiplayer JOIN:
- 1. create player (randomx, randomy)
- 2. connect to server
- 3. send 'join' event to server with client_id, x, y, object_id
- 4. ON 'join', if client_id != my.client_id, create NPC

*/

package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;

import Objects;

class PlayState extends FlxState
{
	var player:Mobile;
	var enemies:FlxTypedGroup<Mobile>;
  
  var client:mphx.client.Client;
  // var client_id:Int;
  var connection_attempts:Int = 0;

	override public function create():Void
	{
		super.create();

		var title = new FlxText(0, 0, 0, "maeve.", 64);
		title.screenCenter();
		add(title);

		player = new Mobile(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height), AssetPaths.player__png);
		player.move('idle');
		add(player);

		enemies = new FlxTypedGroup();
		add(enemies);

		// var enemy = new Mobile(0, 80, AssetPaths.npc__png);
		// enemy.move('right');
		// add(enemy);

    client = new mphx.client.Client("192.168.1.22", 8000);
    // trace(client);
    client.onConnectionError = function (error:Dynamic) {
      trace("On Connection Error:", error, connection_attempts);
      connection_attempts += 1;
      if (connection_attempts <= 10) {
        client.connect();
      }
    };
    client.onConnectionClose = function (error:Dynamic) {
      trace("Connection Closed:", error);
    };
    client.onConnectionEstablished = function () {
      trace('registering??');
      client.send("Register", "HELLO!!!");
    };
    client.connect();

    client.events.on("Registered", function (data) {
    	trace("Registered", data.id);
    	player.client_id = data.id;
    	client.send("Join", {client_id: player.client_id, x: player.x, y: player.y});
    });

    client.events.on("Join", function (data) {
    	trace('join');
    	if (player.client_id != null && player.client_id != data.client_id) {
				var enemy = new Mobile(data.x, data.y, AssetPaths.npc__png);
				enemy.client_id = data.client_id;
				enemies.add(enemy);
				trace('new');   		
    	}
    });

    client.events.on( "Leave", function (data) {
    	trace('leave');
    	for (e in enemies) {
    		if (e.client_id == data.client_id) {
    			enemies.remove(e);
    		}
    	}
    });

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
	    		var enemy = new Mobile(data.x, data.y, AssetPaths.npc__png);
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

		// player.velocity.set(0, 0);

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
			client.send("PlayerData", player.data());
			// trace('what is happening', player.data());
		} 
		#end

		if ( player != null && client.isConnected() ) {
		}
	}
}
