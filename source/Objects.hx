package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;

class Mobile extends FlxSprite {
	// var direction:FlxPoint = new FlxPoint(0, 0);
	var speed:Int = 30;
	var movement:String = "idle";

	public var client_id:Int;

	public function new(x:Float, y:Float, graphic:FlxGraphicAsset) {
		super(x, y);
		this.loadGraphic(graphic, true, 16, 16);
		this.animation.add("up", [4, 5], 6, true);
		this.animation.add("left", [0, 1], 6, true);
		this.animation.add("down", [2, 3], 6, true);
		this.animation.add("right", [6, 7], 6, true);
		this.animation.add("idle", [2], 6, true);		
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