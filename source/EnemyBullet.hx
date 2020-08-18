package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import lime.utils.Assets;

class EnemyBullet extends FlxSprite
{
	public static var BULLET_HEIGHT = 7;
	public static var BULLET_WIDTH = 7;

	public var SPEED = 40;

	public function new(x:Float = 0, y:Float = 0, direction:Float = 90, speed = 60)
	{
		super(x, y);
		SPEED = speed;
		loadGraphic(AssetPaths.enemy_bullet__png, true, BULLET_WIDTH, BULLET_HEIGHT);
		animation.add("NORMAL", [0, 1], 10, true);
		animation.play("NORMAL");
		start(x, y, direction);
	}

	public function start(x:Float = 0, y:Float = 0, direction:Float)
	{
		reset(x, y);
		velocity.set(SPEED, 0);
		velocity.rotate(FlxPoint.weak(0, 0), direction);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!isOnScreen())
			kill();
	}
}
