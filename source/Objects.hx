package;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.addons.display.FlxNestedSprite;

class Hitbox extends FlxObject {
	private var INTERVAL = 2;
	private var timer:Float = 0;
	public var callback:Void->Void;
	public var restore:Void->Void;

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (timer > 0) { 
			timer -= elapsed;
			if (timer <= 0) {
				timer = 0;
				restore();
			}
		}
	}

	public function handleOverlap() {
		if ( timer > 0 ) {
			// nothing
		} else {
			callback();
		}
		timer = INTERVAL;
	}
}

class Mobile extends FlxNestedSprite {
	// var direction:FlxPoint = new FlxPoint(0, 0);
	var speed:Int = 64;
	var movement:String = "idle";

	public var client_id:String;
	public var needs_updating:Bool = false;

	public function new(x:Float, y:Float, graphic:FlxGraphicAsset) {
		super(x, y);
		this.loadGraphic(graphic, true, 16, 16);
		this.animation.add("right", [0, 1, 2, 3], 9, true);
		this.animation.add("up", [4, 5, 6, 7], 9, true);
		this.animation.add("left", [8, 9, 10, 11], 9, true);
		this.animation.add("down", [12, 13, 14, 15], 9, true);
		this.animation.add("idle-right", [0], 6, true);		
		this.animation.add("idle-up", [4], 6, true);		
		this.animation.add("idle-left", [8], 6, true);		
		this.animation.add("idle-down", [12], 6, true);		
		this.move( "right" );
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}

	public function setHitBox(?w:Float = 12, ?h:Float = 12) {
		var offset_w = (this.width - w) / 2;
		var offset_h = (this.height - h) / 2;
		this.width = w;
		this.height = h;
		this.offset.set(offset_w, offset_h);
	}

	public function move(d:String) {
		var old = this.movement;
		if ( old.substr(0, 4) != "idle" && d == "idle" ) {
			this.movement = "idle-" + old;
		} else if ( d != "idle" ) {
			this.movement = d;
		}
		switch (this.movement.split("-")[0]) {
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
		if (this.animation.name != this.movement) {
			trace('hmm', this.animation.name, this.movement);
			this.needs_updating = true;
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