package;

import Explosion;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxTiledSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import haxe.Timer;

typedef HiScore =
{
	var name:String;
	var score:Int;
}

class TitleState extends FlxState
{
	var background:FlxBackdrop;
	var title:FlxSprite;
	var hero:Hero;
	var titleTimeout:FlxTimer;
	var gameOverText:FlxBitmapText;
	var gameStarted:Bool = false;

	var yellowFont:FlxBitmapFont;
	var silverFont:FlxBitmapFont;
	var goldFont:FlxBitmapFont;
	var scoreFont:FlxBitmapFont;
	var highlightScoreFont:FlxBitmapFont;
	var blinkTimer:FlxTimer;

	override public function create()
	{
		silverFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGrid_0.png", "assets/fonts/tacticalbitGrid.fnt");
		goldFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridGold_0.png", "assets/fonts/tacticalbitGrid.fnt");
		yellowFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridYellow_0.png", "assets/fonts/tacticalbitGrid.fnt");
		scoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitScores_0.png", "assets/fonts/tacticalbitScores.fnt");
		highlightScoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitScoresHighlight_0.png", "assets/fonts/tacticalbitScores.fnt");
		Reg.replaying = true;
		FlxG.save.bind("Gamesave");
		if (FlxG.save.data.hiScores == null)
		{
			var _defaultHiscores:Array<HiScore> = [
				{name: "ANA", score: 30000},
				{name: "EDU", score: 20000},
				{name: "GOD", score: 15000},
				{name: "MOM", score: 12500},
				{name: "DAD", score: 11250},
				{name: "LUC", score: 10000},
				{name: "PAC", score: 8000},
				{name: "GUY", score: 5000}
			];
			FlxG.save.data.hiScores = _defaultHiscores;
		}
		FlxG.mouse.visible = false;
		super.create();
		background = new FlxBackdrop("assets/images/background.png", 0, 0, true, true, 0, 0);
		background.velocity.set(0, 28);
		add(background);

		title = new FlxSprite(0, 0, "assets/images/titleBackground.png");
		add(title);

		titleTimeout = new FlxTimer();
		titleTimeout.start(15, timeout, 1);

		gameOverText = new FlxBitmapText(silverFont);
		gameOverText.text = "PRESS X+C \n TO START";
		gameOverText.alignment = FlxTextAlign.CENTER;
		gameOverText.letterSpacing = 1;
		gameOverText.lineSpacing = 1;
		gameOverText.padding = 0;
		gameOverText.x = FlxG.width / 2 - gameOverText.width / 2;
		gameOverText.y = FlxG.height / 2 + 48;
		gameOverText.scrollFactor.set(0, 0);
		add(gameOverText);

		blinkTimer = new FlxTimer();
		blinkTimer.start(0.9, hideText, 1);
		/*
			if (Reg.replaying)
			{
				trace('attract mode started');
				startAttractMode();
			}
			else
			{
				FlxG.vcr.stopReplay();
			}
		 */
	}

	function hideText(timer:FlxTimer)
	{
		gameOverText.visible = false;
		timer.start(0.25, showText, 1);
	}

	function showText(timer:FlxTimer)
	{
		gameOverText.visible = true;
		timer.start(0.9, hideText, 1);
	}

	function timeout(timer:FlxTimer)
	{
		FlxG.switchState(new HiScoresState()); // startAttractMode();
	}

	function startAttractMode()
	{
		FlxG.vcr.loadReplay(FlxG.save.data.attractMode, new PlayState(), ["ENTER"], null, restartGame);
	}

	function restartGame()
	{
		// Reg.replaying = false;
		FlxG.vcr.stopReplay();
		FlxG.switchState(new TitleState());
	}

	function startGame(timer:FlxTimer)
	{
		Reg.replaying = false;
		FlxG.switchState(new PlayState());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyPressed([C]) && FlxG.keys.anyPressed([X]) && !gameStarted)
		{
			gameStarted = true;
			blinkTimer.active = false;
			gameOverText.visible = true;
			FlxFlicker.flicker(gameOverText, 4.5);
			gameOverText.text = "LET'S GO!";
			gameOverText.x = FlxG.width / 2 - gameOverText.width / 2;
			gameOverText.y = FlxG.height / 2 + 48;
			var _timer = new FlxTimer();
			_timer.start(1.5, startGame, 1);
			titleTimeout.active = false;
			FlxG.sound.play('assets/sounds/startgame.wav', 1, false);
			//	continueGame();
		}
	}
}
