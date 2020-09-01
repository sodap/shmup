package;

import Explosion;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.editors.tiled.TiledMap;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import haxe.Timer;
import lime.utils.Assets;
import sys.io.File;

class HudText extends FlxBitmapText
{
	var highlightFont:FlxBitmapFont;
	var normalFont:FlxBitmapFont;

	override public function new(?font:FlxBitmapFont, highlightFont:FlxBitmapFont)
	{
		super(font);
		this.highlightFont = highlightFont;
		this.normalFont = font;
	}

	public function highlight()
	{
		this.font = highlightFont;
		var _timer = new FlxTimer();
		_timer.start(0.05, restoreFont, 1);
	}

	public function restoreFont(timer:FlxTimer)
	{
		this.font = normalFont;
	}
}

class PlayState extends FlxState
{
	var background:FlxBackdrop;
	var hero:Hero;
	var heroBullets:FlxTypedGroup<HeroBullet>;
	var enemyBullets:FlxTypedGroup<EnemyBullet>;
	var explosions:FlxTypedGroup<Explosion>;
	var bombEffects:FlxTypedGroup<BombFx>;
	var smallPlanes:FlxTypedGroup<SmallPlane>;
	var bombs:FlxTypedGroup<BombPickup>;
	var powerups:FlxTypedGroup<Powerup>;
	var medals:FlxTypedGroup<Medal>;
	var enemies:FlxTypedGroup<Enemy>;

	public var rank:Int = 1;
	public var maxRank:Int = 9;

	public var lives:Int = 3;
	public var loops = 0;
	public var score:Int = 0;
	public var bombAmmo:Int = 3;

	var yellowFont:FlxBitmapFont;
	var silverFont:FlxBitmapFont;
	var goldFont:FlxBitmapFont;
	var scoreFont:FlxBitmapFont;
	var highlightScoreFont:FlxBitmapFont;

	var scoreText:HudText;
	var rankText:HudText;
	var loopText:HudText;
	var bombsHud:FlxTiledSprite;
	var livesHud:FlxTiledSprite;
	var loopCountdown:FlxTimer;
	var continueText:FlxBitmapText;
	var gameOverText:FlxBitmapText;
	var readyText:FlxBitmapText;
	var attractModeText:FlxBitmapText;
	var musicCredits:FlxBitmapText;
	var countDownText:HudText;

	var gameOverCountDown:Int = 9;
	var isGameOver:Bool = false;
	var continueTimer:FlxTimer;

	var explosionSounds:Array<String> = ["explosion0.wav", "explosion1.wav"];

	override public function create()
	{
		Reg.finalScore = 0;
		Reg.inputNewScore = false;

		FlxG.mouse.visible = false;
		super.create();
		background = new FlxBackdrop("assets/images/background.png", 0, 0, true, true, 0, 0);
		background.velocity.set(0, 24 + 4 * rank);
		add(background);

		medals = new FlxTypedGroup();
		add(medals);

		bombs = new FlxTypedGroup();
		add(bombs);

		powerups = new FlxTypedGroup();
		add(powerups);

		heroBullets = new FlxTypedGroup();
		add(heroBullets);

		hero = new Hero(112, 200, heroBullets, this);
		add(hero);

		enemies = new FlxTypedGroup();
		add(enemies);

		enemyBullets = new FlxTypedGroup();
		add(enemyBullets);

		bombEffects = new FlxTypedGroup();
		add(bombEffects);

		explosions = new FlxTypedGroup();
		add(explosions);

		var _timer = new FlxTimer();
		smallPlaneWave(_timer);
		// _timer.start(30, smallPlaneWave, 0);

		/*
			var _timer = new FlxTimer();
			_timer.start(5, spawnBomb, 0);

			var _timer2 = new FlxTimer();
			_timer2.start(8, spawnPowerup, 0); */

		silverFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGrid_0.png", "assets/fonts/tacticalbitGrid.fnt");
		goldFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridGold_0.png", "assets/fonts/tacticalbitGrid.fnt");
		yellowFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridYellow_0.png", "assets/fonts/tacticalbitGrid.fnt");
		scoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitScores_0.png", "assets/fonts/tacticalbitScores.fnt");
		highlightScoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitScoresHighlight_0.png", "assets/fonts/tacticalbitScores.fnt");

		if (Reg.replaying)
		{
			trace('attract mode started');
			startAttractMode();
		}
		else
		{
			FlxG.vcr.stopReplay();
			FlxG.sound.playMusic("assets/music/bomblastic.ogg", 0.46, true);
		}
		createHud(4, 4);
	}

	function startRecording()
	{
		if (!Reg.recording)
		{
			Reg.replaying = false;
			Reg.recording = true;
			FlxG.vcr.startRecording(false);
		}
	}

	function loadReplay()
	{
		Reg.replaying = true;
		Reg.recording = false;
		var save:String = FlxG.vcr.stopRecording(false);
		sys.io.File.saveContent("assets/data/attract.dnv", save);
		FlxG.save.data.attractMode = save;
		var _replay:String = sys.io.File.getContent("assets/data/attract.dnv");
		FlxG.vcr.loadReplay(_replay, new PlayState(), [], null, startAttractMode);
	}

	function startAttractMode()
	{
		var _replay:String = sys.io.File.getContent("assets/data/attract.dnv");
		FlxG.vcr.loadReplay(_replay, FlxG.state, ["ANY"], null, endAttractMode);
	}

	function endAttractMode()
	{
		FlxG.vcr.stopReplay();
		FlxG.switchState(new TitleState());
	}

	function restartGame()
	{
		// Reg.replaying = false;
		FlxG.vcr.stopReplay();
		FlxG.switchState(new PlayState());
	}

	function startPlaying()
	{
		Reg.replaying = false;
		trace(${Reg.replaying});
		restartGame();
	}

	function hideRecommendedMusic(timer:FlxTimer)
	{
		var tween1 = FlxTween.tween(musicCredits, {alpha: 0}, 1, {ease: FlxEase.quadOut});
	}

	function createHud(marginX:Float, marginY:Float)
	{
		var lineHeight = 9;
		var hudY = -3 + marginY;

		if (!Reg.replaying) // FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			var theme:String = FlxG.random.getObject(['BOMBLASTIC\nby hernán marandino']);
			musicCredits = new FlxBitmapText(silverFont);
			musicCredits = new FlxBitmapText(silverFont);
			musicCredits.text = 'music:\n$theme';
			musicCredits.alignment = FlxTextAlign.LEFT;
			musicCredits.letterSpacing = 1;
			musicCredits.lineSpacing = 1;
			musicCredits.padding = 0;
			musicCredits.x = -2 + marginX * 3;
			musicCredits.y = FlxG.height - 80;
			var _ntimer = new FlxTimer();
			_ntimer.start(5, hideRecommendedMusic, 1);
			musicCredits.scrollFactor.set(0, 0);
			add(musicCredits);
		}

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

		rankText = new HudText(scoreFont, highlightScoreFont);
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

		continueText = new FlxBitmapText(silverFont);
		continueText.text = 'CONTINUE WITH\n50% SCORE?\n\n\n\n(PRESS SPACE)';
		continueText.alignment = FlxTextAlign.CENTER;
		continueText.letterSpacing = 1;
		continueText.lineSpacing = 1;
		continueText.padding = 0;
		continueText.x = FlxG.width / 2 - continueText.width / 2;
		continueText.y = FlxG.height / 2 - 50;
		continueText.scrollFactor.set(0, 0);
		add(continueText);

		gameOverText = new FlxBitmapText(silverFont);
		gameOverText.text = "GAME OVER";
		gameOverText.alignment = FlxTextAlign.CENTER;
		gameOverText.letterSpacing = 1;
		gameOverText.lineSpacing = 1;
		gameOverText.padding = 0;
		gameOverText.x = FlxG.width / 2 - gameOverText.width / 2;
		gameOverText.y = FlxG.height / 2;
		gameOverText.scrollFactor.set(0, 0);
		add(gameOverText);

		readyText = new FlxBitmapText(silverFont);
		readyText.text = "READY!";
		readyText.alignment = FlxTextAlign.CENTER;
		readyText.letterSpacing = 1;
		readyText.lineSpacing = 1;
		readyText.padding = 0;
		readyText.x = FlxG.width / 2 - readyText.width / 2;
		readyText.y = FlxG.height / 2 - readyText.height / 2;
		readyText.scrollFactor.set(0, 0);

		attractModeText = new FlxBitmapText(silverFont);
		attractModeText.text = "DEMO MODE\n PRESS ANY KEY";
		attractModeText.alignment = FlxTextAlign.CENTER;
		attractModeText.letterSpacing = 1;
		attractModeText.lineSpacing = 1;
		attractModeText.padding = 0;
		attractModeText.x = FlxG.width / 2 - attractModeText.width / 2;
		attractModeText.y = FlxG.height / 2 - attractModeText.height / 2;
		attractModeText.scrollFactor.set(0, 0);
		if (Reg.replaying)
		{
			add(attractModeText);
			var blinkTimer = new FlxTimer();
			blinkTimer.start(0.9, hideAttractModeText, 1);
		}
		else
		{
			add(readyText);
			FlxFlicker.flicker(readyText, 3, 0.3, false);
		}

		countDownText = new HudText(scoreFont, highlightScoreFont);
		countDownText.text = "9";
		countDownText.alignment = FlxTextAlign.CENTER;
		countDownText.letterSpacing = 1;
		countDownText.lineSpacing = 1;
		countDownText.padding = 0;
		countDownText.x = FlxG.width / 2 - countDownText.width / 2;
		countDownText.y = FlxG.height / 2;
		countDownText.scrollFactor.set(0, 0);
		add(countDownText);

		scoreText = new HudText(scoreFont, highlightScoreFont);
		scoreText.text = "00000000";
		scoreText.alignment = FlxTextAlign.CENTER;
		scoreText.letterSpacing = 1;
		scoreText.lineSpacing = 1;
		scoreText.padding = 0;
		scoreText.x = FlxG.width / 2 - scoreText.width / 2;
		scoreText.y = scoreTitle.y + lineHeight;
		scoreText.scrollFactor.set(0, 0);
		scoreText.fieldWidth = scoreText.textWidth - 20;
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

		loopText = new HudText(scoreFont, highlightScoreFont);
		loopText.text = "[0]";
		loopText.alignment = FlxTextAlign.RIGHT;
		loopText.letterSpacing = 1;
		loopText.lineSpacing = 1;
		loopText.padding = 0;
		loopText.x = FlxG.width - (loopText.width - 5) - marginX;
		loopText.y = loopTitle.y + lineHeight;
		loopText.scrollFactor.set(0, 0);
		add(loopText);

		bombsHud = new FlxTiledSprite(AssetPaths.bombHud__png, 0, 14, true, false);
		bombsHud.scrollFactor.set(0, 0);
		bombsHud.x = FlxG.width - 4 - bombsHud.width;
		bombsHud.y = FlxG.height - 4 - bombsHud.height;
		updateBombsHud(hero.bombs);
		add(bombsHud);

		livesHud = new FlxTiledSprite(AssetPaths.livesHud__png, 0, 14, true, false);
		livesHud.scrollFactor.set(0, 0);
		livesHud.x = 4;
		livesHud.y = FlxG.height - 4 - bombsHud.height;
		updateLivesHud(lives);
		add(livesHud);

		hideContinueHud();
	}

	function hideAttractModeText(timer:FlxTimer)
	{
		attractModeText.visible = false;
		timer.start(0.45, showAttractModeText, 1);
	}

	function showAttractModeText(timer:FlxTimer)
	{
		attractModeText.visible = true;
		timer.start(1.5, hideAttractModeText, 1);
	}

	function showContinueHud()
	{
		gameOverCountDown = 9;
		countDownText.text = '$gameOverCountDown';

		continueText.visible = true;
		countDownText.visible = true;
	}

	function hideContinueHud()
	{
		continueText.visible = false;
		countDownText.visible = false;
		gameOverText.visible = false;
	}

	function startCountDown()
	{
		showContinueHud();
		continueTimer = new FlxTimer();
		continueTimer.start(1.5, updateCountDown, 1);
	}

	function updateCountDown(timer:FlxTimer)
	{
		if (isGameOver)
		{
			if (gameOverCountDown > 0)
			{
				timer.start(1.5, updateCountDown, 1);
				gameOverCountDown--;
				FlxG.sound.play('assets/sounds/ticks.wav', 1, false);
				updateCountdownHud(gameOverCountDown);
			}
			else
			{
				Reg.finalScore = score;
				hideContinueHud();
				gameOverText.visible = true;
				for (i in 0...8)
				{
					trace('Is it $i highscore');
					if (Reg.finalScore > FlxG.save.data.hiScores[i].score)
					{
						Reg.inputNewScore = true;
						trace('new hiscore! position: i');
						break;
					}
				}
				FlxG.sound.play('assets/sounds/gameover.wav', 1, false);
				if (FlxG.sound.music != null && FlxG.sound.music.playing)
					FlxG.sound.music.stop();
				Reg.goToTitle = true;
				Reg.finalScore = score;
				var _timer = new FlxTimer();
				_timer.start(3, goToHiscores, 0);
			}
		}
	}

	function goToHiscores(timer:FlxTimer)
	{
		FlxG.switchState(new HiScoresState());
	}

	public function updateBombsHud(_bombs:Int)
	{
		bombsHud.width = 10 * _bombs;
		bombsHud.x = FlxG.width - 4 - bombsHud.width;
		bombsHud.visible = _bombs > 0;
	}

	public function updateLivesHud(_lives:Int)
	{
		livesHud.width = 12 * _lives;
		livesHud.visible = _lives > 0;
	}

	public function increaseRank()
	{
		rank = Std.int(FlxMath.bound(rank + 1, 1, maxRank));
		updateRankHud(rank);
	}

	public function updateRankHud(rank:Int = 1)
	{
		rankText.text = '[ $rank ]';
		rankText.highlight();
	}

	public function updateCountdownHud(countdown:Int = 1)
	{
		countDownText.text = '$countdown';
		countDownText.highlight();
	}

	function updateScoreText(_score:Int)
	{
		scoreText.text = StringTools.lpad('$_score', "0", 8);
		scoreText.highlight();
	}

	function updateLoopText(_loop:Int)
	{
		loopText.text = '[ $loops ]';
		loopText.highlight();
	}

	function spawnBomb(x:Float, y:Float):BombPickup
	{
		var newBomb = new BombPickup(x, y);
		bombs.add(newBomb);
		newBomb.x = FlxMath.bound(x, 5, FlxG.width - 5 - newBomb.width);
		newBomb.y = FlxMath.bound(y, 5, FlxG.height - 5 - newBomb.height);
		return newBomb;
	}

	function spawnPowerup(x:Float, y:Float):Powerup
	{
		var newPowerup = new Powerup(x, y);
		powerups.add(newPowerup);
		newPowerup.x = FlxMath.bound(x, 5, FlxG.width - 5 - newPowerup.width);
		newPowerup.y = FlxMath.bound(y, 5, FlxG.height - 5 - newPowerup.height);
		return newPowerup;
	}

	function spawnMedal(x:Float, y:Float):Medal
	{
		var newPowerup = new Medal(x, y);
		medals.add(newPowerup);
		newPowerup.x = FlxMath.bound(x, 5, FlxG.width - 5 - newPowerup.width);
		newPowerup.y = FlxMath.bound(y, 5, FlxG.height - 5 - newPowerup.height);
		newPowerup.velocity.set(background.velocity.x, background.velocity.y);
		return newPowerup;
	}

	function checkWinCondition()
	{
		var _anyAlive = false;
		for (enemy in enemies)
		{
			_anyAlive = !enemy.ended;
		}
		return !_anyAlive;
	}

	function loopGame(countDown:Float = 0.01)
	{
		if (loopCountdown == null)
			loopCountdown = new FlxTimer();
		if (!loopCountdown.active)
		{
			loops++;
			updateLoopText(loops);
			loopCountdown.start(countDown, smallPlaneWave, 1);
		}
	}

	function smallPlaneWave(timer:FlxTimer)
	{
		// 2
		addEnemy(30, -50, 2, SmallPlane, false, true);
		addEnemy(FlxG.width - 30, -50, 2, SmallPlane, false, false, true);

		// 3.5
		addEnemy(30, -50, 3.5, SmallPlane);
		addEnemy(FlxG.width - 30, -50, 3.5, SmallPlane);

		// 5
		for (i in 0...2)
		{
			addEnemy(30 + 30 * i, -50, 5, SmallPlane);
			addEnemy(FlxG.width / 2 - 10 + 30 * i, -50, 5, SmallPlane);
			addEnemy(FlxG.width - 30 - 30 * i, -50, 5, SmallPlane);
		}
		addEnemy(FlxG.width / 2, -50, 5, SmallPlane, enemyBullets, true, false);

		// 7.25
		addEnemy(FlxG.width / 2 - 30, -50, 7.25, RedPlane, enemyBullets);
		addEnemy(FlxG.width / 2 + 30, -50, 7.25, RedPlane, enemyBullets, false, true);

		// 9

		addEnemy(FlxG.width + 5, 220, 9, MediumPlane, enemyBullets);
		addEnemy(FlxG.width + 5, 180, 9, MediumPlane, enemyBullets, true, false);
		addEnemy(FlxG.width + 5, 140, 9, MediumPlane, enemyBullets);

		// 11

		addEnemy(-26, 220, 11, MediumPlane, enemyBullets);
		addEnemy(-26, 180, 11, MediumPlane, enemyBullets, false, true);
		addEnemy(-26, 140, 11, MediumPlane, enemyBullets);

		// 14
		addEnemy(FlxG.width - 30, -50, 14, SmallPlane);
		addEnemy(FlxG.width - 60, -50, 14, SmallPlane);
		addEnemy(FlxG.width - 90, -50, 14, SmallPlane);

		// 16-17.5
		addEnemy(FlxG.width / 2 + 1, -50, 16, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 16.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 17, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 17.5, RedPlane, enemyBullets, false, false);

		// 18
		addEnemy(30, -50, 18, SmallPlane);
		addEnemy(60, -50, 18, SmallPlane);
		addEnemy(90, -50, 18, SmallPlane);

		// 20-21-5
		addEnemy(FlxG.width / 2 + 1, -50, 20, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 20, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 20, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 20, RedPlane, enemyBullets, false, false);
		for (i in 0...2)
		{
			addEnemy(30 + 30 * i, -50, 20.5, SmallPlane);
			addEnemy(FlxG.width / 2 - 10 + 30 * i, -50, 21, SmallPlane);
			addEnemy(FlxG.width - 30 - 30 * i, -50, 21.5, SmallPlane);
		}

		// 22
		addEnemy(9, FlxG.height, 22, MediumPlane, enemyBullets, false, false, true);
		addEnemy(9, FlxG.height + 40, 22, MediumPlane, enemyBullets, false, true);
		addEnemy(9, FlxG.height + 80, 22, MediumPlane, enemyBullets);

		// 25
		addEnemy(FlxG.width - 35, FlxG.height, 25, MediumPlane, enemyBullets, false, false, true);
		addEnemy(FlxG.width - 35, FlxG.height + 40, 25, MediumPlane, enemyBullets, true, false);
		addEnemy(FlxG.width - 35, FlxG.height + 80, 25, MediumPlane, enemyBullets);

		// 30
		addEnemy(FlxG.width - 60, FlxG.height + 10, 30, BigPlane, enemyBullets, true, true, true);

		// 35
		addEnemy(9, FlxG.height, 35, MediumPlane, enemyBullets, false, false, true);
		addEnemy(9, FlxG.height + 40, 35, MediumPlane, enemyBullets, false, true);
		addEnemy(9, FlxG.height + 80, 35, MediumPlane, enemyBullets);

		// 38
		addEnemy(FlxG.width - 35, FlxG.height, 38, MediumPlane, enemyBullets, false, false, true);
		addEnemy(FlxG.width - 35, FlxG.height + 40, 38, MediumPlane, enemyBullets, true, false);
		addEnemy(FlxG.width - 35, FlxG.height + 80, 38, MediumPlane, enemyBullets);

		// 37-40.5
		addEnemy(FlxG.width / 2 + 1, -50, 37, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 37.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 38, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 38.5, RedPlane, enemyBullets, false, false, true);
		addEnemy(FlxG.width / 2 + 1, -50, 39, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 39.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 40, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 40.5, RedPlane, enemyBullets, false, false);

		// 42-46
		addEnemy(9, FlxG.height, 42, MediumPlane, enemyBullets);
		addEnemy(FlxG.width - 35, FlxG.height, 43, MediumPlane, enemyBullets);
		addEnemy(30, -50, 44, SmallPlane, false, true);
		addEnemy(FlxG.width - 30, -50, 44, SmallPlane, false, false, true);
		addEnemy(9, FlxG.height, 45, MediumPlane, enemyBullets);
		addEnemy(FlxG.width - 35, FlxG.height, 46, MediumPlane, enemyBullets);

		// 47
		for (i in 0...2)
		{
			addEnemy(30 + 30 * i, -50, 47, SmallPlane);
			addEnemy(FlxG.width / 2 - 10 + 30 * i, -50, 47, SmallPlane);
			addEnemy(FlxG.width - 30 - 30 * i, -50, 47, SmallPlane);
		}

		// 49
		for (i in 0...2)
		{
			addEnemy(30 + 30 * i, -50, 47, SmallPlane);
			addEnemy(FlxG.width / 2 - 10 + 30 * i, -50, 49, SmallPlane);
			addEnemy(FlxG.width - 30 - 30 * i, -50, 49, SmallPlane);
		}

		// 51
		for (i in 0...2)
		{
			addEnemy(30 + 30 * i, -50, 51, SmallPlane);
			addEnemy(FlxG.width / 2 - 10 + 30 * i, -50, 51, SmallPlane);
			addEnemy(FlxG.width - 30 - 30 * i, -50, 51, SmallPlane);
		}

		// 53-54.5
		addEnemy(FlxG.width / 2 + 1, -50, 53, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 53.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 54, RedPlane, enemyBullets, false, false, true);
		addEnemy(FlxG.width / 2 - 32, -50, 54.5, RedPlane, enemyBullets, false, false);

		// 53-58
		addEnemy(9, FlxG.height, 53, MediumPlane, enemyBullets);
		addEnemy(FlxG.width - 35, FlxG.height, 53.5, MediumPlane, enemyBullets, false, false, true);
		addEnemy(30, -50, 54, SmallPlane, false, true);
		addEnemy(FlxG.width - 30, -50, 54.5, SmallPlane);
		addEnemy(9, FlxG.height, 55, MediumPlane, enemyBullets, false, false, true);
		addEnemy(FlxG.width - 35, FlxG.height, 55.5, MediumPlane, enemyBullets);
		addEnemy(9, FlxG.height, 56, MediumPlane, enemyBullets);
		addEnemy(FlxG.width - 35, FlxG.height, 56.5, MediumPlane, enemyBullets);
		addEnemy(30, -50, 44, SmallPlane, false, true);
		addEnemy(FlxG.width - 30, -50, 57, SmallPlane);
		addEnemy(9, FlxG.height, 57.5, MediumPlane, enemyBullets);
		addEnemy(FlxG.width - 35, FlxG.height, 58, MediumPlane, enemyBullets, false, false, true);

		// 66
		addEnemy(FlxG.width / 2 + 80, FlxG.height + 20, 64, BigPlane, enemyBullets, true, true, true);
		addEnemy(FlxG.width / 2 - 80, FlxG.height + 45, 64, BigPlane, enemyBullets, true, true, true);
		addEnemy(FlxG.width / 2 + 1, -50, 65, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 65.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 68, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 68.5, RedPlane, enemyBullets, false, false, true);
		addEnemy(FlxG.width / 2 + 1, -50, 69, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 69.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 70, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 70.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 1, -50, 71, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 71.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 72, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 72.5, RedPlane, enemyBullets, false, false, true);
		addEnemy(FlxG.width / 2 + 1, -50, 73, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 73.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 74, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 74.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 1, -50, 75, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 75.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 78, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 78.5, RedPlane, enemyBullets, false, false, true);
		addEnemy(FlxG.width / 2 + 1, -50, 79, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 + 32, -50, 79.5, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 1, -50, 80, RedPlane, enemyBullets, false, false);
		addEnemy(FlxG.width / 2 - 32, -50, 80.5, RedPlane, enemyBullets, false, false);

		// 11

		/*
			for (i in 1...5)
			{
				addEnemy(FlxG.width + 5, 220, 3 * i, MediumPlane, enemyBullets, false, true);
				addEnemy(FlxG.width + 5, 180, 3 * i, MediumPlane, enemyBullets, true, false);
				addEnemy(FlxG.width + 5, 140, 3 * i, MediumPlane, enemyBullets);
				addEnemy(-26, 200, 3 * i, MediumPlane, enemyBullets);
			}

			addEnemy(80, -50, 2.5, RedPlane, enemyBullets);
			addEnemy(FlxG.width - 80, -50, 2.5, SmallPlane);

			addEnemy(30, -50, 4, SmallPlane);
			addEnemy(FlxG.width / 2, -50, 4, RedPlane, enemyBullets, true, false);
			addEnemy(FlxG.width - 30, -50, 5, SmallPlane);

			addEnemy(30, -50, 8, SmallPlane);
			addEnemy(FlxG.width - 30, -50, 7, RedPlane, enemyBullets, false, true);
			addEnemy(FlxG.width / 2, -50, 8, SmallPlane);

			addEnemy(80, -50, 9, SmallPlane);
			addEnemy(FlxG.width - 80, -50, 9, SmallPlane, true);

			addEnemy(30, -50, 10.5, SmallPlane);
			addEnemy(FlxG.width / 2, -50, 10.5, SmallPlane, false, true);
			addEnemy(FlxG.width - 30, -50, 10.5, SmallPlane);

			addEnemy(30, -50, 14, SmallPlane);
			addEnemy(FlxG.width / 2, -50, 12, SmallPlane, true);
			addEnemy(FlxG.width - 30, -50, 12, SmallPlane);

			addEnemy(30, -50, 13.5, SmallPlane);
			addEnemy(FlxG.width - 30, -50, 14, SmallPlane);
			addEnemy(FlxG.width / 2, -50, 14.5, SmallPlane);

			addEnemy(FlxG.width - 60, FlxG.height + 10, 18.5, BigPlane, enemyBullets, false, true);
		 */
	}

	function addEnemy(x:Float, y:Float, time:Float, ObjectClass:Class<Enemy>, bulletGroup:FlxTypedGroup<EnemyBullet> = null, spawnBomb:Bool = false,
			spawnPowerup:Bool = false, spawnMedal:Bool = false)
	{
		var _newPlane = Type.createInstance(ObjectClass, [x, y, time, rank, loops, bulletGroup]);
		_newPlane.spawnPowerup = spawnPowerup;
		_newPlane.spawnBomb = spawnBomb;
		_newPlane.spawnMedal = spawnMedal;
		_newPlane.reset(x, y);
		enemies.add(_newPlane);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.overlap(heroBullets, enemies, destroyEnemy);
		FlxG.overlap(enemyBullets, hero, killHero);
		FlxG.overlap(enemies, hero, killHero);
		FlxG.overlap(hero, bombs, getBomb);
		FlxG.overlap(hero, powerups, getPowerup);
		FlxG.overlap(hero, medals, getMedal);

		if (checkWinCondition())
		{
			loopGame(1.5);
			trace('game won');
		}

		for (bomb in bombs)
		{
			if (Math.abs(bomb.x - hero.x) < 16 && Math.abs(bomb.y - hero.y) < 16)
			{
				bomb.x = FlxMath.lerp(bomb.x, hero.x, 0.35);
				bomb.y = FlxMath.lerp(bomb.y, hero.y, 0.35);
			}
		}

		for (medal in medals)
		{
			if (!medal.taken && Math.abs(medal.x - hero.x) < 16 && Math.abs(medal.y - hero.y) < 16)
			{
				medal.x = FlxMath.lerp(medal.x, hero.x, 0.35);
				medal.y = FlxMath.lerp(medal.y, hero.y, 0.35);
			}
		}

		for (powerup in powerups)
		{
			if (Math.abs(powerup.x - hero.x) < 16 && Math.abs(powerup.y - hero.y) < 16)
			{
				powerup.x = FlxMath.lerp(powerup.x, hero.x, 0.35);
				powerup.y = FlxMath.lerp(powerup.y, hero.y, 0.135);
			}
		}

		if (FlxG.keys.anyJustPressed([SPACE, ENTER, ONE, SHIFT, CONTROL]) && isGameOver)
		{
			continueGame();
			FlxG.sound.play('assets/sounds/continue.wav', 1, false);
		}
		if (FlxG.keys.anyJustPressed([X, O]) && isGameOver)
		{
			if (gameOverCountDown > 0)
			{
				continueTimer.start(1.5, updateCountDown, 1);
				gameOverCountDown--;
				FlxG.sound.play('assets/sounds/ticks.wav', 1, false);
				updateCountdownHud(gameOverCountDown);
			}
			else
			{
				continueTimer.start(0.15, updateCountDown, 1);
			}
		}

		if (FlxG.keys.anyPressed([ENTER]) && Reg.replaying)
		{
			//	startPlaying();
		}

		#if DEV
		if (FlxG.keys.justPressed.R)
		{
			startRecording();
			// loadReplay();
		}
		if (FlxG.keys.justPressed.P && Reg.recording)
		{
			loadReplay();
		}
		#end

		if (FlxG.keys.anyJustPressed([BACKSPACE]))
			FlxG.switchState(new PlayState());
	}

	function continueGame()
	{
		isGameOver = false;
		var _timer = new FlxTimer();
		_timer.start(0.25, spawnHero);
		hideContinueHud();
		score = Std.int(score * 0.5);
		lives = 3;
		for (enemy in enemies)
		{
			if (!enemy.started)
			{
				enemy.spawnTimer.active = true;
			}
		}
		updateLivesHud(lives);
		updateScoreText(score);
	}

	function getBomb(hero:Hero, bomb:BombPickup)
	{
		bomb.kill();
		hero.bombs++;
		FlxG.sound.play('assets/sounds/bomb.wav', 0.8, false);
		updateBombsHud(hero.bombs);
	}

	function getPowerup(hero:Hero, powerup:Powerup)
	{
		powerup.kill();
		FlxG.sound.play('assets/sounds/powerup.wav', 0.8, false);
		hero.addPower();
	}

	function getMedal(hero:Hero, powerup:Medal)
	{
		if (!powerup.taken)
		{
			score += 100;
			powerup.pickup();
			FlxG.sound.play('assets/sounds/medal.wav', 0.8, false);
			updateScoreText(score);
		}
	}

	public function useBomb()
	{
		if (hero.bombs > 0)
		{
			var _newBombFX = bombEffects.recycle(BombFx);
			_newBombFX.start(hero.x - _newBombFX.width / 2, hero.y);
			bombEffects.add(_newBombFX);
			hero.bombs--;
			updateBombsHud(hero.bombs);
			FlxG.sound.play('assets/sounds/useBomb.wav', 1, false);
		}

		for (_bullet in enemyBullets)
		{
			_bullet.kill();
		}
		for (_enemy in enemies)
		{
			destroyEnemy(null, _enemy);
		}
	}

	function killHero(enemy:Enemy, hero:Hero)
	{
		if (!hero.invincible)
		{
			var _newExplosion = explosions.recycle(Explosion);
			_newExplosion.start(hero.x - _newExplosion.width / 2, hero.y - _newExplosion.height / 2);
			explosions.add(_newExplosion);
			FlxG.sound.play('assets/sounds/death.wav', 1, false);
			remove(hero);
			lives--;
			hero.kill();
			if (lives > 0)
			{
				var _timer = new FlxTimer();
				_timer.start(1, spawnHero);
			}
			else
			{
				isGameOver = true;
				for (enemy in enemies)
				{
					if (!enemy.started)
					{
						enemy.spawnTimer.active = false;
					}
				}
				startCountDown();
				showContinueHud();
			}
			updateBombsHud(0);
			updateLivesHud(lives);
			rank = Std.int(FlxMath.bound(rank - 3, 1, maxRank));
			updateRankHud(rank);
		}
	}

	function spawnHero(timer:FlxTimer)
	{
		hero = new Hero(112, 200, heroBullets, this);
		updateBombsHud(hero.bombs);
		add(hero);
	}

	function destroyEnemy(bullet:HeroBullet = null, enemy:Enemy)
	{
		if (!enemy.alive || !enemy.isOnScreen())
			return;
		if (enemy.getDamage(bullet == null))
		{
			var _explosionAsset:String = FlxG.random.getObject(explosionSounds);
			FlxG.sound.play('assets/sounds/$_explosionAsset', 1, false);
			if (enemy.spawnBomb)
			{
				spawnBomb(enemy.x, enemy.y);
			}
			if (enemy.spawnPowerup)
			{
				spawnPowerup(enemy.x, enemy.y);
			}
			if (enemy.spawnMedal)
			{
				spawnMedal(enemy.x, enemy.y);
			}

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
			if (Std.int(score / 10000) != Std.int((score + enemy.scoreValue) / 10000))
				increaseRank();

			score += enemy.scoreValue * (1 + loops) + 10 * rank;
			updateScoreText(score);
			enemy.ended = true;
		}
		if (bullet != null)
			bullet.kill();
	}
}
