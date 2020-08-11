package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import lime.utils.Assets;

class HeroBullet extends FlxSprite
{
	public static var BULLET_HEIGHT = 15;
	public static var BULLET_WIDTH = 3;
	public static var SPEED = -250;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.hero_bullet__png, false, BULLET_WIDTH, BULLET_HEIGHT);
		start(x, y);
	}

	public function start(x:Float = 0, y:Float = 0)
	{
		reset(x, y);
		velocity.set(0, SPEED);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (y + height < 0)
			kill();
	}
}
