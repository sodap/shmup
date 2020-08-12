package;

import Enemy;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class SmallPlane extends Enemy
{
	public function new(x:Float = 0, y:Float = 0, timeToSpawn:Float, rank)
	{
		super(x, y, timeToSpawn, rank);
		SPEED = 140 + 5 * rank;
		loadGraphic(AssetPaths.small_plane__png, false, 11, 15);
	}

	override public function start(x:Float = 0, y:Float = 0)
	{
		super.start(x, y);
		angle = 180;
		var direction = 90;
		velocity.set(SPEED, 0);
		velocity.rotate(FlxPoint.weak(0, 0), direction);
		var tween1 = FlxTween.tween(velocity, {y: 0}, 1, {ease: FlxEase.expoIn});
		tween1.onComplete = exitScreen;
	}

	function exitScreen(tween:FlxTween):Void
	{
		var tween1 = FlxTween.tween(velocity, {y: SPEED * 2}, 2, {ease: FlxEase.expoOut});
	}

	override public function getDamage():Bool
	{
		health--;
		if (health <= 0)
		{
			kill();
			return true;
		}
		else
			return false;
	}
}
