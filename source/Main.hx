package;

import flixel.FlxGame;
import openfl.display.Sprite;
import flixel.FlxG;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild( new FlxGame( 320, 240, ConnectState, 1, 60, 60, true ));
	}
}
