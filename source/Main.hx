package;

import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class Main extends Sprite
{
	public function new()
	{
		super();
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		addChild(new FlxGame(224, 256, HiScoresState));
	}

	function onKeyDown(key:KeyboardEvent)
	{
		if (key.charCode == Keyboard.ENTER)
		{
			Reg.replaying = false;
		}
		Reg.lastKey = key.charCode;
	}
}
