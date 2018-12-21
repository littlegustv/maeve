package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;

class Mobile extends FlxSprite {
	var direction:FlxPoint = new FlxPoint(0, 0);
	var speed:Int = 30;

	public function new(x:Float, y:Float, graphic:FlxGraphicAsset) {
		super(x, y);
		this.loadGraphic(graphic, true, 16, 16);
		this.animation.add("up", [4, 5], 6, true);
		this.animation.add("left", [0, 1], 6, true);
		this.animation.add("down", [2, 3], 6, true);
		this.animation.add("right", [6, 7], 6, true);
		this.animation.add("idle", [2], 6, true);		
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		this.velocity.set(this.direction.x * this.speed, this.direction.y * this.speed);
	}

	public function move(d:String) {
		switch (d) {
			case "up":
				this.direction.set(0, -1);
			case "down":
				this.direction.set(0, 1);
			case "right":
				this.direction.set(1, 0);
			case "left":
				this.direction.set(-1, 0);
			case "idle":
				this.direction.set(0, 0);
		}
		this.animation.play(d);
	}
}