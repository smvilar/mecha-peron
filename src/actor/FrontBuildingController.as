package actor 
{
	import embed.Assets;
	import org.flixel.*;
	import sprites.SpriteLoader;
	
	/**
	 * ...
	 * @author Santiago Vilar
	 */
	public class FrontBuildingController extends ActorController
	{
		private const NUM_BUILDINGS:uint = 3;
		private const Graphics:Array = new Array(Assets.SpriteForegroundA, Assets.SpriteForegroundB, Assets.SpriteForegroundC);
		private const Defs:Array = new Array(Assets.XMLSpriteForegroundA, Assets.XMLSpriteForegroundB, Assets.XMLSpriteForegroundC);
		
		private static var _lastRandom:uint;
		
		private var _playerController:PlayerController;
		
		public function FrontBuildingController(playerController:PlayerController):void
		{
			_playerController = playerController;
		}
		
		override public function init():void 
		{
			var random:uint;
			do {
				random = uint(FlxU.random() * NUM_BUILDINGS);
			} while (random == _lastRandom);
			_lastRandom = random;
			
			//trace("random building: ", random);
			new SpriteLoader().loadIntoSprite(controlledActor, Defs[random], Graphics[random]);
			
			controlledActor.solid = false;
		}
		
		override public function preFirstUpdate():void 
		{
			controlledActor.y = FlxG.height - controlledActor.height;
		}
		
		override public function update():void 
		{
			if (_playerController.usingRightArm)
			{
				var player:Actor = _playerController.controlledActor;
				var playerX:Number = player.getScreenXY().x;
				var thisX:Number = controlledActor.getScreenXY().x;
				if (playerX + player.width > thisX)
				{
					trace("this building dies!");
					controlledActor.play("damage");
				}
			}
		}
	}
}