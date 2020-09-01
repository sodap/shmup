package;

import Explosion;
import TitleState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxTiledSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.input.FlxKeyManager;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import haxe.Timer;

// import cpp.NativeString;
class HiScoresState extends FlxState
{
	var background:FlxBackdrop;
	var title:FlxSprite;
	var hero:Hero;
	var titleTimeout:FlxTimer;
	var hiScoreText:FlxBitmapText;
	var newScoreText:FlxBitmapText;
	var scoreTextCursor:FlxBitmapText;
	var titleText:FlxBitmapText;
	var nameText:FlxBitmapText;
	var posText:FlxBitmapText;
	var gameStarted:Bool = false;

	var yellowFont:FlxBitmapFont;
	var silverFont:FlxBitmapFont;
	var goldFont:FlxBitmapFont;
	var scoreFont:FlxBitmapFont;
	var highlightScoreFont:FlxBitmapFont;
	var addItemTimer:FlxTimer;

	var isTypingNewName:Bool = false;
	var typingCursorPos:Int = 0;
	var newScorePos:Int = 1;
	var goToTitle:Bool = false;

	override public function create()
	{
		silverFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGrid_0.png", "assets/fonts/tacticalbitGrid.fnt");
		goldFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridGold_0.png", "assets/fonts/tacticalbitGrid.fnt");
		yellowFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitGridYellow_0.png", "assets/fonts/tacticalbitGrid.fnt");
		scoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitScores_0.png", "assets/fonts/tacticalbitScores.fnt");
		highlightScoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/tacticalbitScoresHighlight_0.png", "assets/fonts/tacticalbitScores.fnt");
		Reg.replaying = true;
		goToTitle = Reg.inputNewScore;
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
		background = new FlxBackdrop("assets/images/hiscoresBackground.png", 0, 0, true, true, 0, 0);
		// background.velocity.set(0, 28);
		add(background);

		/*title = new FlxSprite(0, 0, "assets/images/titleBackground.png");
			add(title); */

		if (!Reg.inputNewScore)
		{
			titleTimeout = new FlxTimer();
			titleTimeout.start(20, timeout, 1);
		}

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
		hiScoreText.x = FlxG.width - 18 - hiScoreText.width;
		hiScoreText.y = 80;
		hiScoreText.scrollFactor.set(0, 0);
		add(hiScoreText);

		nameText = new FlxBitmapText(silverFont);
		nameText.text = "";
		nameText.alignment = FlxTextAlign.LEFT;
		nameText.fieldWidth = 50;
		nameText.letterSpacing = 1;
		nameText.lineSpacing = 1;
		nameText.padding = 0;
		nameText.x = 60;
		nameText.y = 80;
		nameText.scrollFactor.set(0, 0);
		add(nameText);

		posText = new FlxBitmapText(goldFont);
		posText.text = '1st\n2nd\n3rd\n4th\n5th\n6th\n7th\n8th';
		posText.alignment = FlxTextAlign.RIGHT;
		posText.fieldWidth = 50;
		posText.letterSpacing = 1;
		posText.lineSpacing = 1;
		posText.padding = 0;
		posText.x = 18;
		posText.y = 80;
		posText.scrollFactor.set(0, 0);
		add(posText);

		addItemTimer = new FlxTimer();
		var _loops:Int = 8; // FlxG.save.data.hiScores.length; // - 1;
		var _addHiscoreInterval = Reg.inputNewScore ? 0.03 : 0.9;
		addItemTimer.start(_addHiscoreInterval, addItem, _loops);
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

	function addNewScoreText(pos:Float)
	{
		newScoreText = new FlxBitmapText(goldFont);
		newScoreText.text = "";
		newScoreText.alignment = FlxTextAlign.LEFT;
		newScoreText.fieldWidth = 50;
		newScoreText.letterSpacing = 1;
		newScoreText.lineSpacing = 1;
		newScoreText.padding = 0;
		newScoreText.x = 60;
		newScoreText.y = pos;
		newScoreText.scrollFactor.set(0, 0);
		add(newScoreText);
		addNewScoreCursor();
	}

	function addNewScoreCursor()
	{
		scoreTextCursor = new FlxBitmapText(silverFont);
		scoreTextCursor.text = "_";
		scoreTextCursor.alignment = FlxTextAlign.LEFT;
		scoreTextCursor.fieldWidth = 50;
		scoreTextCursor.letterSpacing = 1;
		scoreTextCursor.lineSpacing = 1;
		scoreTextCursor.padding = 0;
		scoreTextCursor.x = newScoreText.x;
		scoreTextCursor.y = newScoreText.y;
		scoreTextCursor.scrollFactor.set(0, 0);
		add(scoreTextCursor);
		var _blinkTimer = new FlxTimer();
		isTypingNewName = true;
		typingCursorPos = 0;
		_blinkTimer.start(0.1, blinkCursor, 0);
	}

	function blinkCursor(timer:FlxTimer)
	{
		if (isTypingNewName)
			scoreTextCursor.visible = !scoreTextCursor.visible;
		else
			timer.destroy();
	}

	function addItem(timer:FlxTimer)
	{
		var _score = FlxG.save.data.hiScores[timer.elapsedLoops - 1].score;
		var _name = FlxG.save.data.hiScores[timer.elapsedLoops - 1].name;
		var scoreTable:Array<HiScore> = FlxG.save.data.hiScores;
		if (Reg.inputNewScore && _score < Reg.finalScore)
		{
			_score = Reg.finalScore;
			_name = '';
			Reg.inputNewScore = false;
			Reg.finalScore = 0;
			newScorePos = timer.elapsedLoops;
			scoreTable.insert(timer.elapsedLoops - 1, {score: _score, name: _name});
			scoreTable.pop();
			FlxG.save.data.hiScores = scoreTable;
			addNewScoreText((timer.elapsedLoops - 1) * 17 + nameText.y);
		}

		// nameText.text += '${timer.elapsedLoops}. ${_name} \n';
		nameText.text += '${_name} \n';

		hiScoreText.text += '${_score} \n';

		hiScoreText.x = FlxG.width - 18 - hiScoreText.width;
	}

	function timeout(timer:FlxTimer)
	{
		startAttractMode();
	}

	function startAttractMode()
	{
		if (Reg.goToTitle)
		{
			Reg.goToTitle = false;
			FlxG.switchState(new TitleState());
		}
		else
		{
			var _replay:String = openfl.Assets.getText("assets/data/attract.dnv");
			Reg.attractMode = _replay;
			FlxG.vcr.loadReplay(_replay, new PlayState(), ["ENTER", "X", "C", "O", "P", "SPACE", "ENTER", "ONE", "SHIFT", "CONTROL"], null, restartGame);
		}
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

	function hideNewName(timer:FlxTimer)
	{
		newScoreText.visible = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (isTypingNewName)
		{
			if (newScoreText.text.length > 0)
			{
				scoreTextCursor.x = newScoreText.x + newScoreText.textWidth - 10;
			}
			if (FlxG.keys.anyJustPressed([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z]))
			{
				var _string = String.fromCharCode(Reg.lastKey).toUpperCase();
				newScoreText.text += _string;
				FlxG.sound.play('assets/sounds/type.wav', 1, false);
				// scoreTextCursor.x += 11;
				if (newScoreText.text.length >= 3)
				{
					FlxG.save.data.hiScores[newScorePos - 1].name = newScoreText.text;
					isTypingNewName = false;
					scoreTextCursor.visible = false;
					var _timer = new FlxTimer();
					_timer.start(0.2, hideNewName, 1);
					nameText.text = "";
					for (i in 0...8)
					{
						var _name = FlxG.save.data.hiScores[i].name;
						nameText.text += '${_name} \n';
					}
					titleTimeout = new FlxTimer();
					titleTimeout.start(10, timeout, 1);
				}
			}
		}
		else
		{
			if (FlxG.keys.anyPressed([X, C, O, P, SPACE, ENTER, ONE, SHIFT, CONTROL]))
			{
				FlxG.switchState(new TitleState());
			}
		}

		if (FlxG.keys.anyPressed([X, C, O, P, SPACE, ENTER, ONE, SHIFT, CONTROL]) && !gameStarted)
		{
			FlxG.switchState(new TitleState());
		}

		/*
			if (FlxG.keys.anyJustPressed([ENTER]) && !gameStarted)
			{
				Reg.inputNewScore = true;
				Reg.finalScore = 53040;
				FlxG.switchState(new HiScoresState());
			}
		 */
	}
}
