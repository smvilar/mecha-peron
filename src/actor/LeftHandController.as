package actor 
{
	import embed.Assets;
	import game.Configuration;
	import org.flixel.*;
	/**
	 * ...
	 * @author Santiago Vilar
	 */
	public class LeftHandController extends ActorController 
	{
		
		public function LeftHandController() 
		{
			
		}
		
		override public function init():void
		{
			controlledActor.fixed = true;
			
			controlledActor.loadGraphic(Assets.SpriteFist, true, false, 44, 30);
			
			controlledActor.addAnimation("launch", [0, 1, 2], 16, false);
			controlledActor.addAnimation("fly", [3, 4], 16, true);
			controlledActor.addAnimationCallback(animationCallback);
		}
		
		override public function update():void
		{
			if (!controlledActor.onScreen())
			{
				controlledActor.exists = false;
			}
		}
		
		override public function onHurt(Damage:Number):Boolean
		{
			return false;
		}
		
		override public function onKill():Boolean 
		{
			FlxG.play(Assets.SfxBigExplosion, Configuration.soundVolume);
			
			controlledActor.layer.add(new Actor(new ExplosionController(),
				controlledActor.layer,
				controlledActor.x + controlledActor.width,
				controlledActor.y + controlledActor.height / 2));
			
			return true;
		}
		
		private function animationCallback(name:String, frameNumber:uint, frameIndex:uint):void
		{
			if (name == "launch" && controlledActor.finished)
			{
				controlledActor.play("fly");
			}
		}
	}
}