package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class Enemy extends FlxSprite
{
	public var SPEED = 40;
	public var BASESPEED = 40;
	public var scoreValue = 10;

	var rank:Int = 1;
	var loop:Int = 0;
	var bullets:FlxGroup; // TypedGroup<EnemyBullet>;

	public var started = false;

	var appeared = false;

	public var ended = false;

	public var spawnBomb = false;
	public var spawnPowerup = false;
	public var spawnMedal = false;
	public var spawnTimer:FlxTimer;

	public function new(x:Float = 0, y:Float = 0, timeToSpawn:Float, rank:Int = 1, loop:Int = 1, bullets = null)
	{
		super(x, y);
		this.rank = rank;
		this.loop = loop;
		this.bullets = bullets;
		loadGraphic(AssetPaths.small_plane__png, false, 11, 15);
		this.spawnTimer = new FlxTimer();
		spawnTimer.start(timeToSpawn, spawn, 1);
	}

	function hasEnded():Bool
	{
		if (isOnScreen())
			appeared = true;
		return appeared && !isOnScreen();
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
		started = true;
	}

	public function getDamage(isBombDamage:Bool = false):Bool
	{
		if (alive)
		{
			var _dmg = isBombDamage ? 10 : 1;
			health -= _dmg;
		}
		return false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!ended)
		{
			ended = hasEnded();
			if (ended)
				trace('enemy exit');
		}
	}
}
