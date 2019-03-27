package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class SettingsController
{
	var volume:Float = 0.5;

	public function enableMenu( settings_group:FlxGroup ) {
		trace( 'enable settings' );
		settings_group.visible = true;
	}

	public function disableMenu( settings_group:FlxGroup ) {
		trace( 'disable settings' );
		settings_group.visible = false;
	}

	public function new( settings_group:FlxGroup ) {
		trace( 'new settingscontroller' );
		var underlay = new FlxSprite( 0, 0 );
		underlay.makeGraphic( FlxG.width, FlxG.height, FlxColor.BLACK );
		underlay.scrollFactor.set( 0, 0 );
		underlay.alpha = 0.5;

		var box = new FlxSprite( FlxG.width / 2 - 50, FlxG.height / 2 - 25 );
		box.makeGraphic( 100, 50, FlxColor.WHITE );
		box.scrollFactor.set( 0, 0 );

	    // var title = new FlxText( 0, 0, "Volume" , 16 );
	    var title = new FlxText( FlxG.width / 2 - 50, FlxG.height / 2 - 25, 100, "Volume" , 16 );
	    title.addFormat(new FlxTextFormat( FlxColor.BLACK ) );
	    title.scrollFactor.set( 0, 0 );
	    title.alignment = FlxTextAlign.CENTER;

		settings_group.add( underlay );
		settings_group.add( box );
		settings_group.add( title );

	  	// settings_group.visible = false;
		trace( 'end settingscontroller' );
	}

	public function create():Void {
		trace( 'create' );
	}
}