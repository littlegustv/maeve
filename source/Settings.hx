package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class SettingsController
{
	var volume:Int = 5;
	var volume_level:FlxText;

	public function increaseVolume() {
		this.volume = FlxMath.minInt( this.volume + 1, 10 );
		this.volume_level.text = '' + this.volume;
		FlxG.sound.volume = this.volume / 10;
	}

	public function decreaseVolume() {
		this.volume = FlxMath.maxInt( this.volume - 1, 0 );
		this.volume_level.text = '' + this.volume;
		FlxG.sound.volume = this.volume / 10;
	}

	public function enableMenu( settings_group:FlxGroup ) {
		settings_group.visible = true;
	}

	public function disableMenu( settings_group:FlxGroup ) {
		settings_group.visible = false;
	}

	public function new( settings_group:FlxGroup ) {
		var underlay = new FlxSprite( 0, 0 );
		underlay.makeGraphic( FlxG.width, FlxG.height, FlxColor.BLACK );
		underlay.scrollFactor.set( 0, 0 );
		underlay.alpha = 0.5;

		var box = new FlxSprite( FlxG.width / 2 - 50, FlxG.height / 2 - 25 );
		box.makeGraphic( 100, 50, FlxColor.WHITE );
		box.scrollFactor.set( 0, 0 );

	    var title = new FlxText( FlxG.width / 2 - 50, FlxG.height / 2 - 25, 100, 'Volume' , 16 );
	    title.addFormat(new FlxTextFormat( FlxColor.BLACK ) );
	    title.scrollFactor.set( 0, 0 );
	    title.alignment = FlxTextAlign.CENTER;

	    this.volume_level = new FlxText( FlxG.width / 2 - 50, FlxG.height / 2, 100, '' + this.volume , 16 );
	    this.volume_level.addFormat(new FlxTextFormat( FlxColor.BLACK ) );
	    this.volume_level.scrollFactor.set( 0, 0 );
	    this.volume_level.alignment = FlxTextAlign.CENTER;

		settings_group.add( underlay );
		settings_group.add( box );
		settings_group.add( title );
		settings_group.add( this.volume_level );

	  	settings_group.visible = false;

		FlxG.sound.volume = this.volume / 10;
	}
}