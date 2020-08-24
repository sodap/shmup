package;

import Enemy;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class BigPlane extends Enemy
{
	var autoShootTimer:FlxTimer;
	var FIRE_RATE:Float = 4;

	public function new(x:Float = 0, y:Float = 0, timeToSpawn:Float, rank, loop:Int = 1, bullets = null)
	{
		super(x, y, timeToSpawn, rank, loop, bullets);
		this.scoreValue = 1500;
		loadGraphic(AssetPaths.big_plane__png, true, 53, 50);
		animation.add("NORMAL", [0], 10, true);
		animation.add("HIT", [1], 20, false);
		animation.play("NORMAL");
		setDifficulty();
		animation.finishCallback = onAnimationFinished;
		autoShootTimer = new FlxTimer();
	}

	function setDifficulty()
	{
		SPEED = Std.int(BASESPEED * 0.5) + 4 * rank + 2 * loop;
		health = 90 + Std.int(4 * rank) + Std.int(loop * 2);
		FIRE_RATE = 2 + FlxMath.bound((2 - 0.1 * rank - 0.1 * loop), 0, 2);
	}

	function onAnimationFinished(_anim_name:String)
	{
		animation.play("NORMAL");
	}

	override public function start(x:Float = 0, y:Float = 0)
	{
		super.start(x, y);
		setDifficulty();
		angle = 0;
		var direction = x > FlxG.width / 2 ? -120 : 30;
		velocity.set(SPEED, 0);
		velocity.rotate(FlxPoint.weak(0, 0), direction);
		// tween1.onUpdate = shoot;
		autoShootTimer.start(FIRE_RATE);
		// timer.start(1.5, shoot, 1);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (isOnScreen())
		{
			if (x < FlxG.width / 2 - 60)
				var tween1 = FlxTween.tween(this, {"velocity.x": SPEED}, 1, {ease: FlxEase.quadOut});
			if (x + width > FlxG.width / 2 + 60)
				var tween1 = FlxTween.tween(this, {"velocity.x": -SPEED}, 1, {ease: FlxEase.quadOut});
			if (y < FlxG.height / 2 - 60)
				var tween1 = FlxTween.tween(this, {"velocity.y": SPEED}, 1, {ease: FlxEase.quadOut});
			if (y + height > FlxG.height / 2 + 60)
				var tween1 = FlxTween.tween(this, {"velocity.y": -SPEED}, 1, {ease: FlxEase.quadOut});

			shoot();
		}
	}

	function shoot()
	{
		if (!autoShootTimer.active)
		{
			var shotPos = getGraphicMidpoint();
			var bulletSeparation = 30; // degrees
			var numberOfBullets = Std.int(360 / bulletSeparation);
			for (i in 0...numberOfBullets)
			{
				var bullet1:EnemyBullet = new EnemyBullet(shotPos.x, shotPos.y, bulletSeparation * i);

				bullets.add(bullet1);
			}

			autoShootTimer.start(FIRE_RATE);
		}
	}

	override public function getDamage(isBombDamage:Bool = false):Bool
	{
		if (alive)
		{
			super.getDamage(isBombDamage);
			animation.play("HIT");
			if (health <= 0)
			{
				kill();
				return true;
			}
			else
				return false;
		}
		else
			return false;
	}
}
