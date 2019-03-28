package;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.addons.display.FlxNestedSprite;
import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;

class Fighter extends FlxSprite {
	public override function update( elapsed:Float ) {
		this.angle += 2 * Math.PI * elapsed;
		this.velocity.set( 150 * Math.cos( FlxAngle.TO_RAD * this.angle ), 150 * Math.sin( FlxAngle.TO_RAD * this.angle ));
		super.update(elapsed);
	}
}

class Enemy extends FlxSprite {
	public var tween:FlxTween;
	public var index:Int;
}

class Console extends FlxSprite {
	public var weapon:FlxSprite;
	public var user:Mobile;
	public var uid:String;
	public var type:String = "weapons";
}

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
		// this.animation.add("right", [0, 1, 2, 3], 9, true);
		// this.animation.add("up", [4, 5, 6, 7], 9, true);
		// this.animation.add("left", [8, 9, 10, 11], 9, true);
		// this.animation.add("down", [12, 13, 14, 15], 9, true);
		// this.animation.add("idle-right", [0], 6, true);		
		// this.animation.add("idle-up", [4], 6, true);		
		// this.animation.add("idle-left", [8], 6, true);		
		// this.animation.add("idle-down", [12], 6, true);		
		// this.animation.add("right", [1, 2], 9, true);
		// this.animation.add("up", [4, 5], 9, true);
		// this.animation.add("left", [7, 8], 9, true);
		// this.animation.add("down", [10, 11], 9, true);
		// this.animation.add("idle-right", [0], 6, true);		
		// this.animation.add("idle-up", [3], 6, true);		
		// this.animation.add("idle-left", [6], 6, true);		
		// this.animation.add("idle-down", [9], 6, true);		
		
		this.animation.add("jump-up", [0,1,2], 9, false);
		this.animation.add("up", [3,4], 9, true);
		this.animation.add("idle-up", [3], 9, true);
		this.animation.add("jump-down", [5,6,7], 9, false);
		this.animation.add("down", [8,9], 9, true);
		this.animation.add("idle-down", [8], 9, true);
		this.animation.add("jump-left", [10,11,12], 9, false);
		this.animation.add("left", [13,14], 9, true);
		this.animation.add("idle-left", [13], 9, true);
		this.animation.add("jump-right", [15,16,17], 9, false);
		this.animation.add("right", [18,19], 9, true);
		this.animation.add("idle-right", [18], 9, true);
		this.animation.finishCallback = function ( name:String ) {
			if ( name.substr(0, 4) == 'jump' ) {
				this.animation.play( this.movement );
			}
		}

		this.move( "right" );
		this.move( "idle" );
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
		if ( this.animation.name != null && this.animation.name.substr(0, 4) != "jump" ) {			
			if (this.animation.name != this.movement) {
				// trace('hmm', this.animation.name, this.movement);
				this.needs_updating = true;
			}
			this.animation.play(this.movement);
		}
	}

	public function jump () {
		var direction = StringTools.replace( this.movement, "idle-", "" );
		this.animation.play("jump-" + direction);
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