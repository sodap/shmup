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

class HiScoresState extends FlxState
{
	var background:FlxBackdrop;
	var title:FlxSprite;
	var hero:Hero;
	var titleTimeout:FlxTimer;
	var hiScoreText:FlxBitmapText;
	var titleText:FlxBitmapText;
	var nameText:FlxBitmapText;
	var gameStarted:Bool = false;

	var yellowFont:FlxBitmapFont;
	var silverFont:FlxBitmapFont;
	var goldFont:FlxBitmapFont;
	var scoreFont:FlxBitmapFont;
	var highlightScoreFont:FlxBitmapFont;
	var addItemTimer:FlxTimer;

	override public function create()
	{
		silverFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGrid_0.png", "assets/fonts/tacticalbitGrid.fnt");
		goldFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridGold_0.png", "assets/fonts/tacticalbitGrid.fnt");
		yellowFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridYellow_0.png", "assets/fonts/tacticalbitGrid.fnt");
		scoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitScores_0.png", "assets/fonts/tacticalbitScores.fnt");
		highlightScoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitScoresHighlight_0.png", "assets/fonts/tacticalbitScores.fnt");
		Reg.replaying = true;
		FlxG.save.bind("Gamesave");
		FlxG.mouse.visible = false;
		super.create();
		background = new FlxBackdrop("assets/images/hiscoresBackground.png", 0, 0, true, true, 0, 0);
		// background.velocity.set(0, 28);
		add(background);

		/*title = new FlxSprite(0, 0, "assets/images/titleBackground.png");
			add(title); */

		titleTimeout = new FlxTimer();
		titleTimeout.start(22, timeout, 1);

		titleText = new FlxBitmapText(yellowFont);
		titleText.text = "HI - SCORES";
		titleText.alignment = FlxTextAlign.CENTER;
		titleText.letterSpacing = 1;
		titleText.lineSpacing = 3;
		titleText.padding = 0;
		titleText.x = FlxG.width / 2 - titleText.width / 2;
		titleText.y = 50;
		titleText.scrollFactor.set(0, 0);
		add(titleText);

		hiScoreText = new FlxBitmapText(scoreFont);
		hiScoreText.text = "";
		hiScoreText.alignment = FlxTextAlign.RIGHT;
		hiScoreText.letterSpacing = 1;
		hiScoreText.lineSpacing = 3;
		hiScoreText.padding = 0;
		hiScoreText.x = FlxG.width - 50 - hiScoreText.width;
		hiScoreText.y = 80;
		hiScoreText.scrollFactor.set(0, 0);
		add(hiScoreText);

		nameText = new FlxBitmapText(silverFont);
		nameText.text = "";
		nameText.alignment = FlxTextAlign.RIGHT;
		nameText.fieldWidth = 50;
		nameText.letterSpacing = 1;
		nameText.lineSpacing = 1;
		nameText.padding = 0;
		nameText.x = 40;
		nameText.y = 80;
		nameText.scrollFactor.set(0, 0);
		add(nameText);

		addItemTimer = new FlxTimer();
		var _loops:Int = 8; // FlxG.save.data.hiScores.length; // - 1;
		addItemTimer.start(0.9, addItem, _loops);
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

	function addItem(timer:FlxTimer)
	{
		nameText.text += '${timer.elapsedLoops}. ${FlxG.save.data.hiScores[timer.elapsedLoops - 1].name} \n';

		hiScoreText.text += '${FlxG.save.data.hiScores[timer.elapsedLoops - 1].score} \n';

		hiScoreText.x = FlxG.width - 40 - hiScoreText.width;
	}

	function timeout(timer:FlxTimer)
	{
		startAttractMode();
	}

	function startAttractMode()
	{
		var _replay:String = sys.io.File.getContent("assets/data/attract.dnv");
		FlxG.vcr.loadReplay(_replay, new PlayState(), ["ENTER"], null, restartGame);
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

		if (FlxG.keys.anyJustPressed([SPACE]) && !gameStarted)
		{
			FlxG.switchState(new TitleState());
		}
	}
}
