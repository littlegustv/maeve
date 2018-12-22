package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

import Objects;

class MenuState extends FlxState
{
  var client:mphx.client.Client;
  var connection_attempts:Int = 0;
  
  var rooms:Array<FlxText>;
  var room_index = 0;

	override public function create():Void
	{
		super.create();

		var instructions = new FlxText(0, 0, 0, "Rooms:", 8);
		add(instructions);

		client = new mphx.client.Client("192.168.1.22", 8000);
    client.onConnectionError = function (error:Dynamic) {
      trace("On Connection Error:", error.keys, connection_attempts);
      connection_attempts += 1;
      if (connection_attempts <= 10) {
        client.connect();
      }
    };
    client.onConnectionClose = function (error:Dynamic) {
      trace("Connection Closed:", error);
    };
    client.onConnectionEstablished = function () {
      trace('gettings rooms');
      client.send("GetRooms");
    };
    client.events.on("RoomsData", function (data:Dynamic) {
    	trace("ROOMS LIST: ", data.rooms);
    	rooms = new Array<FlxText>();
    	for (i in 0...data.rooms.length) {
    		var room = new FlxText(0, ( i + 1 ) * 10, 0, data.rooms[i], 8);
    		rooms.push(room);
    		add(room);
    	}
    });
    client.events.on("JoinedRoom", function (data) {
    	trace("joined room!!");
    	FlxG.switchState(new PlayState(client));
    });
    client.connect();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// if (FlxG.keys.pressed.ANY) {
		// 	FlxG.switchState(new PlayState());
		// }

		if (FlxG.keys.justPressed.UP) {
			rooms[room_index].color = FlxColor.WHITE;
			room_index = (room_index - 1) % rooms.length;
			rooms[room_index].color = FlxColor.RED;
		}
		if (FlxG.keys.justPressed.DOWN) {
			rooms[room_index].color = FlxColor.WHITE;
			room_index = (room_index + 1) % rooms.length;
			rooms[room_index].color = FlxColor.RED;
		}

		if (FlxG.keys.justPressed.ENTER) {
			client.send("JoinRoom", { room: rooms[room_index].text } );
		}

	}

}