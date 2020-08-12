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
	var enemies:FlxTypedGroup<Enemy>;
	var rank:Int = 1;

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

		enemies = new FlxTypedGroup();
		add(enemies);
		var _timer = new FlxTimer();
		smallPlaneWave(_timer);
		_timer.start(19, smallPlaneWave, 4);
	}

	function smallPlaneWave(timer:FlxTimer)
	{
		for (i in 0...2)
		{
			addEnemy(30 + 20 * i, -50, 2, SmallPlane);
			addEnemy(FlxG.width / 2 - 10 + 20 * i, -50, 2, SmallPlane);
			addEnemy(FlxG.width - 30 - 20 * i, -50, 2, SmallPlane);
		}

		addEnemy(80, -50, 3, SmallPlane);
		addEnemy(FlxG.width - 80, -50, 3, SmallPlane);

		addEnemy(30, -50, 4, SmallPlane);
		addEnemy(FlxG.width / 2, -50, 5, SmallPlane);
		addEnemy(FlxG.width - 30, -50, 6, SmallPlane);

		addEnemy(30, -50, 8, SmallPlane);
		addEnemy(FlxG.width - 30, -50, 8, SmallPlane);
		addEnemy(FlxG.width / 2, -50, 9, SmallPlane);

		addEnemy(80, -50, 10, SmallPlane);
		addEnemy(FlxG.width - 80, -50, 10, SmallPlane);

		addEnemy(30, -50, 12, SmallPlane);
		addEnemy(FlxG.width / 2, -50, 12, SmallPlane);
		addEnemy(FlxG.width - 30, -50, 12, SmallPlane);

		addEnemy(30, -50, 14, SmallPlane);
		addEnemy(FlxG.width / 2, -50, 14, SmallPlane);
		addEnemy(FlxG.width - 30, -50, 14, SmallPlane);

		addEnemy(30, -50, 17, SmallPlane);
		addEnemy(FlxG.width - 30, -50, 18, SmallPlane);
		addEnemy(FlxG.width / 2, -50, 19, SmallPlane);
	}

	function addEnemy(x:Float, y:Float, time:Float, ObjectClass:Class<Enemy>)
	{
		var _newPlane = Type.createInstance(ObjectClass, [x, y, time, rank]);
		enemies.add(_newPlane);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.overlap(heroBullets, enemies, destroyEnemy);
		FlxG.overlap(enemies, hero, killHero);
	}

	function killHero(enemy:Enemy, hero:Hero)
	{
		if (!hero.invincible)
		{
			remove(hero);
			hero.kill();
			var _timer = new FlxTimer();
			_timer.start(1, spawnHero);
		}
	}

	function spawnHero(timer:FlxTimer)
	{
		hero = new Hero(112, 200, heroBullets);
		add(hero);
	}

	function destroyEnemy(bullet:HeroBullet, enemy:Enemy)
	{
		enemy.getDamage();
		bullet.kill();
	}
}
