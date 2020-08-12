package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class Enemy extends FlxSprite
{
	public var SPEED = 40;

	var rank:Int = 1;

	public function new(x:Float = 0, y:Float = 0, timeToSpawn:Float, rank:Int = 1)
	{
		super(x, y);
		this.rank = rank;
		loadGraphic(AssetPaths.small_plane__png, false, 11, 15);
		var _spawnTimer = new FlxTimer();
		_spawnTimer.start(timeToSpawn, spawn, 1);
	}

	function spawn(timer:FlxTimer)
	{
		start(x, y);
	}

	public function start(x:Float = 0, y:Float = 0)
	{
		reset(x, y);
		velocity.set(SPEED, 0);
		angle = 180;
	}

	public function getDamage():Bool
	{
		return false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
