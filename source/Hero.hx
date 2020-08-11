package;

import HeroBullet;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class Hero extends FlxSprite
{
	var autoShootTimer:FlxTimer;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
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
		if (_bool)
			return 1;
		else
			return 0;
	}

	function handleMovement()
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);

		velocity.x = 0;
		velocity.y = 0;

		// UPLEFT = -4, UP = -3, UPRIGHT = -2, LEFT = 1, RIGHT = 1, DOWNLEFT = 2, DOWN = 3, DOWNRIGHT = 4
		var directions = [225, 270, 315, 180, 0, 0, 135, 90, 45];
		var h_axis = boolToInt(right) - boolToInt(left);
		var v_axis = (boolToInt(down) - boolToInt(up)) * 3;
		var _direction = directions[h_axis + v_axis + 4];
		var MOVE_LEFT = if (animation.name != "MOVE_LEFT") "TURN_LEFT" else "MOVE_LEFT";
		var MOVE_RIGHT = if (animation.name != "MOVE_RIGHT") "TURN_RIGHT" else "MOVE_RIGHT";
		var animations = [
			MOVE_LEFT,
			"MOVE_UP",
			MOVE_RIGHT,
			MOVE_LEFT,
			"IDLE",
			MOVE_RIGHT,
			MOVE_LEFT,
			"MOVE_UP",
			MOVE_RIGHT
		];
		var _animation = animations[h_axis + v_axis + 4];
		velocity.set(Math.min(100, Math.abs((h_axis + v_axis) * 100)), 0);
		velocity.rotate(FlxPoint.weak(0, 0), _direction);

		animation.play(_animation);
	}

	function shootBullets(power:Int = 1)
	{
		var _shoot = FlxG.keys.anyPressed([CONTROL]) && !autoShootTimer.active;
		if (_shoot)
		{
			var _newBullet = new HeroBullet(x, y - HeroBullet.BULLET_HEIGHT);
			FlxG.state.add(_newBullet);
			autoShootTimer.start(0.2);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		handleMovement();
		shootBullets();
	}
}
