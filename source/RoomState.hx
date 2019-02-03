package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.util.FlxSpriteUtil;

import Objects;

class RoomState extends FlxState
{
  var client:mphx.client.Client;
  var connection_attempts:Int = 0;
  
  // var rooms:Array<FlxText>;
  var room_index = 0;

  var PORT:Int = 8000;
  var HOST:String = "127.0.0.1";

  public function new(client:mphx.client.Client) {
  	super();
  	this.client = client;
  }

	override public function create():Void
	{
		super.create();

		var loading = new FlxText(0, 0, 0, "loading...", 8);
		loading.screenCenter();
		add(loading);

    client.events.on("RoomsData", function (data:Dynamic) {
    	trace('mhmhmafdga');
      trace("ROOMS LIST: ", data.rooms);
    	// rooms = new Array<FlxText>();
    	// var rooms = new FlxUIRadioGroup(0, 10, data.rooms, data.rooms);
    	FlxSpriteUtil.fadeOut(loading);
    	var rooms = new FlxUIDropDownMenu(0, 10, FlxUIDropDownMenu.makeStrIdLabelArray(data.rooms, true));

    	var join_button = new FlxUIButton(0, 32, "Join", function () {
    		// trace('id::', rooms.selectedId, rooms.selectedLabel);
    		client.send( "JoinRoom", { room: rooms.selectedLabel } );
    	});
    	add(join_button);

    	var create_room = new FlxUIInputText(0, 64, 64, "", 8);

    	var create_room_button = new FlxUIButton(0, 80, "Create", function () {
    		// trace("create: ", create_room.text);
    		client.send( "CreateRoom", { room: create_room.text } );
    	});
    	add(create_room_button);
    	add(create_room);
    	add(rooms);
    	// for (i in 0...data.rooms.length) {
    	// 	var room = new FlxText(0, ( i + 1 ) * 10, 0, data.rooms[i], 8);
    	// 	rooms.push(room);
    	// 	add(room);
    	// }
    });
    client.events.on("JoinedRoom", function (data) {
    	trace("joined room!!");
    	FlxG.switchState(new PlayState(client));
    });
  	trace('getting rooms');
  	client.send("GetRooms");
    trace('what');
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// if (FlxG.keys.pressed.ANY) {
		// 	FlxG.switchState(new PlayState());
		// }

		// if (FlxG.keys.justPressed.UP) {
		// 	rooms[room_index].color = FlxColor.WHITE;
		// 	room_index = (room_index - 1) % rooms.length;
		// 	rooms[room_index].color = FlxColor.RED;
		// }
		// if (FlxG.keys.justPressed.DOWN) {
		// 	rooms[room_index].color = FlxColor.WHITE;
		// 	room_index = (room_index + 1) % rooms.length;
		// 	rooms[room_index].color = FlxColor.RED;
		// }

		// if (FlxG.keys.justPressed.ENTER) {
		// 	client.send("JoinRoom", { room: rooms[room_index].text } );
		// }

	}

}