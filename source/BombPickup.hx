package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import lime.utils.Assets;

class BombPickup extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.bomb__png, true, 10, 14);
		animation.add("ROTATE", [0, 0, 1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8], 24, true);
		start(x, y);
	}

	public function start(_x:Float = 0, _y:Float = 0)
	{
		reset(_x, _y);
		animation.play("ROTATE", true);
		velocity.set(20, 20);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (x > (FlxG.width - width - 5) || x < 5)
		{
			velocity.set(-velocity.x, velocity.y);
		}

		if (y > (FlxG.height - height - 20) || y < 5)
		{
			velocity.set(velocity.x, -velocity.y);
		}
	}
}
