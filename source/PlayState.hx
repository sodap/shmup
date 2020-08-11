package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var background:FlxBackdrop;
	var hero:Hero;
	var heroBullets:FlxTypedGroup<HeroBullet>;
	var smallPlanes:FlxTypedGroup<SmallPlane>;
	var enemies:FlxGroup;

	override public function create()
	{
		super.create();
		background = new FlxBackdrop("assets/images/background.png", 0, 0, true, true, 0, 0);
		background.velocity.set(0, 48);
		add(background);
		heroBullets = new FlxTypedGroup();
		hero = new Hero(112, 200, heroBullets);
		add(hero);
		add(heroBullets);

		smallPlanes = new FlxTypedGroup();
		add(smallPlanes);

		enemies = new FlxGroup();
		add(enemies);

		var _spawnTimer = new FlxTimer();
		_spawnTimer.start(2, spawnSmallPlane, 0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.overlap(heroBullets, enemies, destroyEnemy);
	}

	function destroyEnemy(bullet:HeroBullet, enemy:FlxSprite)
	{
		enemy.kill();
		bullet.kill();
	}

	function spawnSmallPlane(timer:FlxTimer)
	{
		var _newPlane = smallPlanes.recycle(SmallPlane);
		_newPlane.start(50, -50);
		smallPlanes.add(_newPlane);
		enemies.add(_newPlane);
	}
}
