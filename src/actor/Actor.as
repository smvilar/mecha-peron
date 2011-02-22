package actor 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Santiago Vilar
	 */
	public class Actor extends FlxSprite
	{
		private var _controller:ActorController;
		
		public function set controller(actorController:ActorController):void
		{
			_controller = actorController;
			_controller.controlledActor = this;
			_controller.init();
		}
		
		public function get controller():ActorController
		{
			return _controller;
		}
		
		public function Actor(actorController:ActorController) 
		{
			controller = actorController;
		}
		
		public override function update():void
		{
			_controller.update();
			super.update();
		}
	}
}