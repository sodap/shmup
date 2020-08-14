package;

import Explosion;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.util.FlxTimer;
import js.html.AbortController;

class PlayState extends FlxState
{
	var background:FlxBackdrop;
	var hero:Hero;
	var heroBullets:FlxTypedGroup<HeroBullet>;
	var enemyBullets:FlxTypedGroup<EnemyBullet>;
	var explosions:FlxTypedGroup<Explosion>;
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
		add(heroBullets);

		hero = new Hero(112, 200, heroBullets);
		add(hero);

		enemies = new FlxTypedGroup();
		add(enemies);

		enemyBullets = new FlxTypedGroup();
		add(enemyBullets);

		explosions = new FlxTypedGroup();
		add(explosions);

		var _timer = new FlxTimer();
		smallPlaneWave(_timer);
		_timer.start(30, smallPlaneWave, 0);
	}

	function smallPlaneWave(timer:FlxTimer)
	{
		addEnemy(FlxG.width - 60, FlxG.height + 10, 2.5, BigPlane, enemyBullets);
		/*
			addEnemy(FlxG.width - 60, FlxG.height + 10, 2.5, BigPlane, enemyBullets);

			for (i in 0...2)
			{
				addEnemy(30 + 20 * i, -50, 2, SmallPlane);
				addEnemy(FlxG.width / 2 - 10 + 20 * i, -50, 2, SmallPlane);
				addEnemy(FlxG.width - 30 - 20 * i, -50, 2, SmallPlane);
			}

			for (i in 1...5)
			{
				addEnemy(FlxG.width + 5, 220, 3 * i, MediumPlane, enemyBullets);
				addEnemy(FlxG.width + 5, 180, 3 * i, MediumPlane, enemyBullets);
				addEnemy(FlxG.width + 5, 140, 3 * i, MediumPlane, enemyBullets);
				addEnemy(-26, 200, 3 * i, MediumPlane, enemyBullets);
			}

			addEnemy(80, -50, 2.5, RedPlane, enemyBullets);
			addEnemy(FlxG.width - 80, -50, 2.5, SmallPlane);

			addEnemy(30, -50, 4, SmallPlane);
			addEnemy(FlxG.width / 2, -50, 4, RedPlane, enemyBullets);
			addEnemy(FlxG.width - 30, -50, 5, SmallPlane);

			addEnemy(30, -50, 8, SmallPlane);
			addEnemy(FlxG.width - 30, -50, 7, RedPlane, enemyBullets);
			addEnemy(FlxG.width / 2, -50, 8, SmallPlane);

			addEnemy(80, -50, 9, SmallPlane);
			addEnemy(FlxG.width - 80, -50, 9, SmallPlane);

			addEnemy(30, -50, 10.5, SmallPlane);
			addEnemy(FlxG.width / 2, -50, 10.5, SmallPlane);
			addEnemy(FlxG.width - 30, -50, 10.5, SmallPlane);

			addEnemy(30, -50, 14, SmallPlane);
			addEnemy(FlxG.width / 2, -50, 12, SmallPlane);
			addEnemy(FlxG.width - 30, -50, 12, SmallPlane);

			addEnemy(30, -50, 13.5, SmallPlane);
			addEnemy(FlxG.width - 30, -50, 14, SmallPlane);
			addEnemy(FlxG.width / 2, -50, 14.5, SmallPlane); */
	}

	function addEnemy(x:Float, y:Float, time:Float, ObjectClass:Class<Enemy>, bulletGroup:FlxTypedGroup<EnemyBullet> = null)
	{
		var _newPlane = Type.createInstance(ObjectClass, [x, y, time, rank, bulletGroup]);
		enemies.add(_newPlane);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.overlap(heroBullets, enemies, destroyEnemy);
		FlxG.overlap(enemyBullets, hero, killHero);
		FlxG.overlap(enemies, hero, killHero);

		if (FlxG.keys.anyJustPressed([ENTER]))
			FlxG.switchState(new PlayState());
	}

	function killHero(enemy:Enemy, hero:Hero)
	{
		if (!hero.invincible)
		{
			var _newExplosion = explosions.recycle(Explosion);
			_newExplosion.start(hero.x - _newExplosion.width / 2, hero.y - _newExplosion.height / 2);
			explosions.add(_newExplosion);
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
		if (enemy.getDamage())
		{
			var _newExplosion = explosions.recycle(Explosion);
			var _nx = enemy.getGraphicMidpoint().x - _newExplosion.width / 2;
			var _ny = enemy.getGraphicMidpoint().y - _newExplosion.height / 2;
			_newExplosion.start(_nx, _ny);
			explosions.add(_newExplosion);
			var _sectors = Std.int(enemy.width / 24);
			var _sector_width = enemy.width / _sectors;
			var _sector_height = enemy.height / _sectors;
			for (i in 0..._sectors)
			{
				var _nx:Float = 0;
				var _ny:Float = 0;
				for (j in 0..._sectors)
				{
					_nx = enemy.x + FlxG.random.float(0 + _sector_width * i, _sector_width * (i + 1)) - _newExplosion.width / 3;
					_ny = enemy.y + FlxG.random.float(0 + _sector_height * j, _sector_height * (j + 1)) - _newExplosion.height / 3;
					var _newExplosion = explosions.recycle(Explosion);
					_newExplosion.start(_nx, _ny);
					explosions.add(_newExplosion);
				}
			}
		}
		bullet.kill();
	}
}
