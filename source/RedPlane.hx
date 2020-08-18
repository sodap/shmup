package;

import Enemy;
import Math;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class RedPlane extends Enemy
{
	public function new(x:Float = 0, y:Float = 0, timeToSpawn:Float, rank, bullets)
	{
		super(x, y, timeToSpawn, rank, bullets);
		this.scoreValue = 50;
		SPEED = 140 + 5 * rank;
		loadGraphic(AssetPaths.red_plane__png, false, 11, 15);
	}

	override public function start(x:Float = 0, y:Float = 0)
	{
		super.start(x, y);
		angle = 180;
		var direction = 90;
		velocity.set(SPEED, 0);
		velocity.rotate(FlxPoint.weak(0, 0), direction);
		var exitSpeed = x < FlxG.width / 2 ? -SPEED : SPEED;
		var tween1 = FlxTween.tween(velocity, {x: exitSpeed, y: 0}, 1, {ease: FlxEase.expoIn});
		tween1.onComplete = exitScreen;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		angle = FlxAngle.getPolarCoords(velocity.x, velocity.y, FlxPoint.weak(0, 0)).y + 90;
	}

	function shoot()
	{
		var shotPos = getGraphicMidpoint();
		var bullet1:EnemyBullet = new EnemyBullet(shotPos.x, shotPos.y, (velocity.x > 0 ? 105 : 75), SPEED);
		bullets.add(bullet1);
	}

	function exitScreen(tween:FlxTween):Void
	{
		shoot();

		/*var orientation = x > FlxG.width / 2 ? 1 : -1;
			var lateral = (x - FlxG.width / 2) / (FlxG.width / 4);
			var tween1 = FlxTween.tween(velocity, {x: lateral * SPEED, y: SPEED * 2}, 2, {ease: FlxEase.expoOut});
		 */
	}

	override public function getDamage(isBombDamage:Bool = false):Bool
	{
		super.getDamage(isBombDamage);
		if (health <= 0)
		{
			kill();
			return true;
		}
		else
			return false;
	}
}
