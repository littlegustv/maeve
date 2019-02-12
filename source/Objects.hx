package;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.addons.display.FlxNestedSprite;

// import mphx.utils.event.impl.ClientEventManager;
// import mphx.serialization.ISerializer;
// import sys.net.Socket;
// import haxe.io.Input;
// import haxe.io.Bytes;
// import mphx.utils.Log;

// class MyClientEventManager extends ClientEventManager {
// 	public function getEventMap() {
// 		return this.eventMap;
// 	}
// 	public override function callEventCallback(eventName:String, data:Dynamic)
// 	{
// 		//If an event with that name exists.
// 		if (eventMap.exists(eventName))
// 		{
// 			//See if the event should be called with or without the sender.
// 			if(eventMap.get(eventName) != null){
// 				// trace("event function exists", eventName, eventMap.get(eventName));
// 				eventMap.get(eventName)(data);
// 			}else{
// 				Log.message(DebugLevel.Info | DebugLevel.Networking,"mphx recieved event type "+eventName+" however no event listener was registered for it.");
// 			}
// 		} else {
// 			trace("event did not exist", eventName);
// 		}
// 	}
// }

class MyClient extends mphx.client.Client {

	// public function new(_ip:String, _port:Int, _serializer : ISerializer = null, _blocking : Bool = false) {
	// 	trace("MYCLIENT");
	// 	super(_ip, _port, _serializer, _blocking);
	// 	events = new MyClientEventManager();
	// }

	// public override function recieve(line:String)
	// {
	// 	var msg = serializer.deserialize(line);
	// 	var key:String = msg.t;
	// 	// trace("Events", key.length, msg.data);			
	// 	events.callEvent(msg.t,msg.data);
	// }
}

class Mobile extends FlxNestedSprite {
	// var direction:FlxPoint = new FlxPoint(0, 0);
	var speed:Int = 64;
	var movement:String = "idle";

	public var client_id:Int;

	public function new(x:Float, y:Float, graphic:FlxGraphicAsset) {
		super(x, y);
		this.loadGraphic(graphic, true, 16, 16);
		this.animation.add("right", [0, 1, 2, 3], 9, true);
		this.animation.add("up", [4, 5, 6, 7], 9, true);
		this.animation.add("left", [8, 9, 10, 11], 9, true);
		this.animation.add("down", [12, 13, 14, 15], 9, true);
		this.animation.add("idle", [12, 13], 6, true);		
		this.move("idle");
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}

	public function move(d:String) {
		this.movement = d;
		switch (this.movement) {
			case "up":
				this.velocity.set(0, -1 * this.speed);
			case "down":
				this.velocity.set(0, 1 * this.speed);
			case "right":
				this.velocity.set(1 * this.speed, 0);
			case "left":
				this.velocity.set(-1 * this.speed, 0);
			case "idle":
				this.velocity.set(0, 0);
		}
		this.animation.play(this.movement);
	}

	public function data() {
		return { client_id: client_id, x: x, y: y, movement: movement };
	}

	public function sync(data) {
		this.x = data.x;
		this.y = data.y;
		this.move(data.movement);
	}
}