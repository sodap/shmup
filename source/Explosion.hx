package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import lime.utils.Assets;

class Explosion extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.explosion_fx__png, true, 32, 32);
		animation.add("EXPLODE", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 12, false);
		start(x, y);
	}

	function onAnimationFinished(_anim_name:String)
	{
		kill();
	}

	public function start(x:Float = 0, y:Float = 0)
	{
		reset(x - 16, y - 16);
		animation.play("EXPLODE", true);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
