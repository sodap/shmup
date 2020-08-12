package;

import Enemy;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class MediumPlane extends Enemy
{
	var hasAmmo = true;

	public function new(x:Float = 0, y:Float = 0, timeToSpawn:Float, rank, bullets = null)
	{
		super(x, y, timeToSpawn, rank, bullets);
		SPEED = 80 + 7 * rank;
		loadGraphic(AssetPaths.medium_plane__png, true, 21, 21);
		animation.add("NORMAL", [0], 10, true);
		animation.add("HIT", [1], 10, false);
		animation.play("NORMAL");
		health = 2 * rank;
		animation.finishCallback = onAnimationFinished;
	}

	function onAnimationFinished(_anim_name:String)
	{
		animation.play("NORMAL");
	}

	override public function start(x:Float = 0, y:Float = 0)
	{
		super.start(x, y);
		angle = 0;
		var direction = x > FlxG.width / 2 ? -180 : 0;
		velocity.set(SPEED, 0);
		velocity.rotate(FlxPoint.weak(0, 0), direction);
		var tween1 = FlxTween.tween(velocity, {x: 0, y: -SPEED}, 1.75, {ease: FlxEase.quadOut});
		tween1.onUpdate = shoot;
		var timer = new FlxTimer();
		// timer.start(1.5, shoot, 1);
	}

	function shoot(tween:FlxTween)
	{
		trace("SHOOT!");
		if (y < 75 && hasAmmo)
		{
			var shotPos = getGraphicMidpoint();
			var bullet1:EnemyBullet = new EnemyBullet(shotPos.x, shotPos.y, 120);
			var bullet2:EnemyBullet = new EnemyBullet(shotPos.x, shotPos.y, 90);
			var bullet3:EnemyBullet = new EnemyBullet(shotPos.x, shotPos.y, 60);
			bullets.add(bullet1);
			bullets.add(bullet2);
			bullets.add(bullet3);

			hasAmmo = false;
		}
	}

	override public function getDamage():Bool
	{
		health--;
		animation.play("HIT");
		if (health <= 0)
		{
			kill();
			return true;
		}
		else
			return false;
	}
}
