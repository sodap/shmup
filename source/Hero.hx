package;

import HeroBullet;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class Hero extends FlxSprite
{
	var autoShootTimer:FlxTimer;
	var SPEED:Float = 180;
	var powerLevel:Int = 1;
	final maxPower:Int = 8;
	var bullets:FlxTypedGroup<HeroBullet>;

	public function new(x:Float = 0, y:Float = 0, bullets)
	{
		super(x, y);
		this.bullets = bullets;
		loadGraphic(AssetPaths.hero_aircraft__png, true, 29, 29);
		width = 4;
		height = 4;
		centerOffsets();
		offset.y -= 4;

		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("TURN_RIGHT", [4, 8], 5, false);
		animation.add("MOVE_RIGHT", [7, 8], 10, true);
		animation.add("TURN_LEFT", [10, 14], 5, false);
		animation.add("MOVE_LEFT", [13, 14], 10, true);
		animation.add("MOVE_UP", [1, 2], 10, true);
		animation.add("IDLE", [0], 10, false);
		animation.play("IDLE");
		animation.finishCallback = onAnimationFinished;
		FlxFlicker.flicker(this, 2);
		autoShootTimer = new FlxTimer();
	}

	function onAnimationFinished(_anim_name:String)
	{
		switch (_anim_name)
		{
			case "TURN_RIGHT":
				animation.play("MOVE_RIGHT");
			case "TURN_LEFT":
				animation.play("MOVE_LEFT");
		}
	}

	function boolToInt(_bool:Bool):Int
	{
		_bool ? return 1 : return 0;
	}

	function handleMovement(up:Bool, down:Bool, left:Bool, right:Bool):Bool
	{
		velocity.x = 0;
		velocity.y = 0;

		var h_axis = boolToInt(right) - boolToInt(left);
		var v_axis = boolToInt(down) - boolToInt(up);

		var direction = FlxAngle.getPolarCoords(h_axis, v_axis, FlxPoint.weak(0, 0)).y;
		var isMoving = h_axis != 0 || v_axis != 0;

		velocity.set(isMoving ? SPEED : 0, 0);
		velocity.rotate(FlxPoint.weak(0, 0), direction);

		// animations
		var MOVE_LEFT = animation.name != "MOVE_LEFT" ? "TURN_LEFT" : "MOVE_LEFT";
		var MOVE_RIGHT = animation.name != "MOVE_RIGHT" ? "TURN_RIGHT" : "MOVE_RIGHT";
		var MOVE_UP = "MOVE_UP";
		var animations = [MOVE_RIGHT, MOVE_RIGHT, MOVE_UP, MOVE_LEFT, MOVE_LEFT];
		animation.play(isMoving ? animations[Std.int(Math.abs(direction / 45))] : "IDLE");

		return isMoving;
	}

	function shootBullets(power:Int = 1)
	{
		trace('power: $powerLevel');
		for (i in 0...(power % 2))
		{
			var _newBullet = bullets.recycle(HeroBullet);
			_newBullet.start(x, y - HeroBullet.BULLET_HEIGHT);
			bullets.add(_newBullet);
		}

		for (i in 1...Std.int(power / (2)) + 1)
		{
			var _newBullet = bullets.recycle(HeroBullet);
			_newBullet.start(x - i * 5, y - HeroBullet.BULLET_HEIGHT + i * 3);
			bullets.add(_newBullet);
			_newBullet = bullets.recycle(HeroBullet);
			_newBullet.start(x + i * 5, y - HeroBullet.BULLET_HEIGHT + i * 3);
			bullets.add(_newBullet);
		}

		autoShootTimer.start(0.2);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var up:Bool = FlxG.keys.anyPressed([UP, W]);
		var down:Bool = FlxG.keys.anyPressed([DOWN, S]);
		var left:Bool = FlxG.keys.anyPressed([LEFT, A]);
		var right:Bool = FlxG.keys.anyPressed([RIGHT, D]);

		var _move = handleMovement(up, down, left, right);
		if (FlxG.keys.anyPressed([CONTROL]) && !autoShootTimer.active)
			shootBullets(powerLevel);
		powerLevel = Std.int(FlxMath.bound(powerLevel + boolToInt(FlxG.keys.anyJustPressed([PAGEDOWN])) - boolToInt(FlxG.keys.anyJustPressed([PAGEUP])), 1,
			maxPower));

		x = FlxMath.bound(x, 0, FlxG.width - 4);
		y = FlxMath.bound(y, 0, FlxG.height - 20);
	}
}
