package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class Medal extends FlxSprite
{
	public var taken = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.medal__png, true, 9, 17);
		animation.add("SHINE", [0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8], 12, true);
		start(x, y);
	}

	public function pickup()
	{
		taken = true;
		loadGraphic(AssetPaths.scorePickup__png, false, 25, 9);
		velocity.set(0, -30);
		var tween1 = FlxTween.tween(velocity, {x: 0, y: 0}, 1, {ease: FlxEase.quadOut});
		var _timer = new FlxTimer();
		_timer.start(1.25, delayedKill, 1);
	}

	function delayedKill(timer:FlxTimer)
	{
		kill();
	}

	public function start(_x:Float = 0, _y:Float = 0)
	{
		reset(_x, _y);
		animation.play("SHINE", true);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (y > FlxG.height)
		{
			kill();
		}
	}
}
