package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import lime.utils.Assets;

class SmallPlane extends FlxSprite
{
	public static var SPEED = 40;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.small_plane__png, false, 11, 15);
		start(x, y);
	}

	public function start(x:Float = 0, y:Float = 0)
	{
		reset(x, y);
		velocity.set(SPEED, 0);
		angle = 180;
		var direction = x > FlxG.width / 2 ? 110 : 70;
		velocity.rotate(FlxPoint.weak(0, 0), direction);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		trace("hello");
	}
}
