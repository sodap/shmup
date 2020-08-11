package;

import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;

class PlayState extends FlxState
{
	var background:FlxBackdrop;

	override public function create()
	{
		super.create();
		background = new FlxBackdrop("assets/images/background.png", 0, 0, true, true, 0, 0);
		background.velocity.set(0, 48);
		add(background);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
