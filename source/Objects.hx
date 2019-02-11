package;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.addons.display.FlxNestedSprite;

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