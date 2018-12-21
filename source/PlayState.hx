package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;

import Objects;

class PlayState extends FlxState
{
	var player:Mobile;
  
  var client:mphx.client.Client;
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

		// var enemy = new Mobile(0, 80, AssetPaths.npc__png);
		// enemy.move('right');
		// add(enemy);

    client = new mphx.client.Client("127.0.0.1", 8000);
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
      client.send("Join", "HELLO!!!");
    };
    client.connect();

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
		#end
	}
}
