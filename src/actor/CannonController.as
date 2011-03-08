package actor 
{
	import level.CannonBomb;
	import org.flixel.*;
	import embed.Assets;
	import flash.geom.Point;
	import game.Constants;
	/**
	 * ...
	 * @author 
	 */
	public class CannonController extends ActorController 
	{
		private var _player:Actor;
		private var _layer:FlxGroup;
		
		private var _visibleTimer:Number;
		
		public function CannonController(player:Actor, layer:FlxGroup) 
		{
			_player = player;
			_layer = layer;
		}
		
		override public function init():void
		{
			controlledActor.loadGraphic(Assets.SpriteCannon, true, false, 19, 23);
			
			controlledActor.addAnimation("leftIdle", new Array(0, 0));
			controlledActor.addAnimation("leftShoot", new Array(1, 1));
			controlledActor.addAnimation("topLeftIdle", new Array(2, 2));
			controlledActor.addAnimation("topLeftShoot", new Array(3, 3));
			controlledActor.addAnimation("topIdle", new Array(4, 4));
			controlledActor.addAnimation("topShoot", new Array(5, 5));
			
			controlledActor.fixed = true;
		}
		
		override public function update():void
		{
			var screenX:Number = controlledActor.getScreenXY().x;
			var screenY:Number = controlledActor.getScreenXY().y;
			
			// camera culling
			controlledActor.visible = (screenX < FlxG.width);
			// mark as dead when it goes out of camera
			if (screenX < -controlledActor.frameWidth)
			{
				controlledActor.kill();
				return;
			}
			
			if (controlledActor.visible)
				_visibleTimer += FlxG.elapsed;
			else
				_visibleTimer = 0;

			var readyToShoot:Boolean = _visibleTimer > Constants.CANNON_ATTACK_DELAY - 1.0;
			if(screenX > FlxG.width - (FlxG.width / 3))
			{
				if (readyToShoot)
					controlledActor.play("leftShoot");
				else
					controlledActor.play("leftIdle");
			}
			else if (screenX > FlxG.width / 3)
			{
				if (readyToShoot)
					controlledActor.play("topLeftShoot");
				else
					controlledActor.play("topLeftIdle");
			}
			else
			{
				if (readyToShoot)
					controlledActor.play("topShoot");
				else
					controlledActor.play("topIdle");
			}
			
			if (_visibleTimer >= Constants.CANNON_ATTACK_DELAY)
			{
				_visibleTimer = 0;
				
				// Randomize target y
				var randomY:Number = FlxU.random() * (_player.height / 4);
				var targetPos:Point = new Point(_player.getScreenXY().x + _player.width / 2, _player.getScreenXY().y + randomY);

				var bomb:CannonBomb = new CannonBomb(_layer, screenX, screenY);
				bomb.x -= FlxG.scroll.x * _layer.scrollFactor.x;
				
				var speed:Point = new Point(targetPos.x - screenX, targetPos.y - screenY);
				speed.normalize(1);
				
				bomb.velocity.x = speed.x * Constants.CANNON_BOMB_SPEED;
				bomb.velocity.y = speed.y * Constants.CANNON_BOMB_SPEED;
				
				_layer.add(bomb, true);
			}
		}
		
		override public function onHurt(Damage:Number):Boolean
		{
			return true;
		}
		
		override public function onKill():Boolean
		{
			return true;
		}
	}

}