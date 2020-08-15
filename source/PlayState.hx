package;

import Explosion;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

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
	var lives:Int = 3;
	var score:Int = 0;
	var yellowFont:FlxBitmapFont;
	var silverFont:FlxBitmapFont;
	var goldFont:FlxBitmapFont;
	var scoreFont:FlxBitmapFont;
	var scoreText:FlxBitmapText;
	var rankText:FlxBitmapText;
	var loopText:FlxBitmapText;

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

		silverFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGrid_0.png", "assets/fonts/tacticalbitGrid.fnt");
		goldFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridGold_0.png", "assets/fonts/tacticalbitGridGold.fnt");
		yellowFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridYellow_0.png", "assets/fonts/tacticalbitGridYellow.fnt");
		scoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitScores_0.png", "assets/fonts/tacticalbitScores.fnt");

		createHud(4, 4);
	}

	function createHud(marginX:Float, marginY:Float)
	{
		var lineHeight = 9;
		var hudY = -3 + marginY;

		var rankTitle = new FlxBitmapText(silverFont);
		rankTitle = new FlxBitmapText(silverFont);
		rankTitle.text = "rank";
		rankTitle.alignment = FlxTextAlign.LEFT;
		rankTitle.letterSpacing = 1;
		rankTitle.lineSpacing = 1;
		rankTitle.padding = 0;
		rankTitle.x = -2 + marginX;
		rankTitle.y = hudY;
		rankTitle.scrollFactor.set(0, 0);
		add(rankTitle);

		rankText = new FlxBitmapText(scoreFont);
		rankText.text = "[1]";
		rankText.alignment = FlxTextAlign.LEFT;
		rankText.letterSpacing = 1;
		rankText.lineSpacing = 1;
		rankText.padding = 0;
		rankText.x = -1 + marginX;
		rankText.y = rankTitle.y + lineHeight;
		rankText.scrollFactor.set(0, 0);
		add(rankText);

		var scoreTitle = new FlxBitmapText(silverFont);
		scoreTitle = new FlxBitmapText(silverFont);
		scoreTitle.text = "score";
		scoreTitle.alignment = FlxTextAlign.CENTER;
		scoreTitle.letterSpacing = 1;
		scoreTitle.lineSpacing = 1;
		scoreTitle.padding = 0;
		scoreTitle.x = FlxG.width / 2 - scoreTitle.width / 2;
		scoreTitle.y = hudY;
		scoreTitle.scrollFactor.set(0, 0);
		add(scoreTitle);

		scoreText = new FlxBitmapText(scoreFont);
		scoreText.text = "00000000";
		scoreText.alignment = FlxTextAlign.CENTER;
		scoreText.letterSpacing = 1;
		scoreText.lineSpacing = 1;
		scoreText.padding = 0;
		scoreText.x = FlxG.width / 2 - scoreText.width / 2;
		scoreText.y = scoreTitle.y + lineHeight;
		scoreText.scrollFactor.set(0, 0);
		scoreText.fieldWidth = scoreText.textWidth - 20;
		trace('score text textwidth: ${scoreText.textWidth} width: ${scoreText.width}');
		add(scoreText);

		var loopTitle = new FlxBitmapText(silverFont);
		loopTitle = new FlxBitmapText(silverFont);
		loopTitle.text = "loop";
		loopTitle.alignment = FlxTextAlign.RIGHT;
		loopTitle.letterSpacing = 1;
		loopTitle.lineSpacing = 1;
		loopTitle.padding = 0;
		loopTitle.x = FlxG.width - (loopTitle.width - 8) - marginX;
		loopTitle.y = hudY;
		loopTitle.scrollFactor.set(0, 0);
		add(loopTitle);

		loopText = new FlxBitmapText(scoreFont);
		loopText.text = "[0]";
		loopText.alignment = FlxTextAlign.RIGHT;
		loopText.letterSpacing = 1;
		loopText.lineSpacing = 1;
		loopText.padding = 0;
		loopText.x = FlxG.width - (loopText.width - 5) - marginX;
		loopText.y = loopTitle.y + lineHeight;
		loopText.scrollFactor.set(0, 0);
		add(loopText);
	}

	function updateScoreText(_score:Int)
	{
		scoreText.text = StringTools.lpad('$_score', "0", 8);
	}

	function smallPlaneWave(timer:FlxTimer)
	{
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
		addEnemy(FlxG.width / 2, -50, 14.5, SmallPlane);

		addEnemy(FlxG.width - 60, FlxG.height + 10, 18.5, BigPlane, enemyBullets);
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
		if (enemy.getDamage()) // if enemy is killed
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
			score += enemy.scoreValue;
			updateScoreText(score);
			trace(score);
		}
		bullet.kill();
	}
}
