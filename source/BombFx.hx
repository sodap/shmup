package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import lime.utils.Assets;

class BombFx extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.bombFX__png, false, 446, 126);
		start(x, y);
	}

	public function start(_x:Float = 0, _y:Float = 0)
	{
		reset(_x, _y);
		velocity.set(0, -400);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (y + height < 0)
			kill();
	}
}
