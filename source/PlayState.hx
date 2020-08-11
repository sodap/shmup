package;

import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;

class PlayState extends FlxState
{
	var background:FlxBackdrop;

	override public function create()
	{
		super.create();
		background = new FlxBackdrop("assets/images/background.png", 0, -4, true, true, 0, 0);
		add(background);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
