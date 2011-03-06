﻿package states 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import actor.*;
	import embed.Assets;
	import level.HUD;
	import level.ParallaxLayer;
	import game.Constants;
	import level.TutorialText;
	import org.flixel.*;
	
	/**
	 * Main Level of the game
	 * @author Santiago Vilar
	 */
	public class MainLevel extends FlxState
	{
		private const RANDOM_VOICEFX_COUNT:uint = 2;
		
		private var _layerBack:ParallaxLayer;
		private var _layerMiddle:ParallaxLayer;
		private var _layerAction:ParallaxLayer;
		private var _layerFront:ParallaxLayer;
		
		private var _player:Actor;
		
		private var _planes:Vector.<Actor> = new Vector.<Actor>();
		
		private var _hud:HUD = new HUD();
		
		private var _distanceTraveled:uint = 0;
		private var _previousDistance:uint;
		
		private var _followBeacon:FlxObject;
		private const FOLLOW_OFFSET:int = 160;
		
		private var _levelStarted:Boolean = false;
		private var _playingTutorial:Boolean = false;
		
		override public function create():void
		{
			bgColor = 0xffd3a9a9;
			_layerBack = new ParallaxLayer(Assets.SpriteBack,		0.2);
			_layerMiddle = new ParallaxLayer(Assets.SpriteMiddle,	0.5);
			_layerAction = new ParallaxLayer(null,					1.0);
			_layerFront = new ParallaxLayer(Assets.SpriteFront,		1.5);
			
			_layerMiddle.addEmitter(130, 80, setupSmoke, startSmoke);
			_layerMiddle.addEmitter(390, 126, setupSmoke, startSmoke);
			
			initPlayer();
			//initLevel();
			
			_layerFront.add(_hud);
			
			add(_layerBack);
			add(_layerMiddle);
			add(_layerAction);
			add(_layerFront);
			
			_previousDistance = _player.x;
			
			FlxG.mouse.load(Assets.SpriteCrosshair, 5, 5);
			FlxG.mouse.show();
		}
		
		private function initPlayer():void
		{
			_player = new CompositeActor(new PlayerController(_layerAction));
			_player.x = -_player.width;
			_player.y = FlxG.height - 222;
			
			_followBeacon = new FlxObject(_player.x + FOLLOW_OFFSET, _player.y);
			FlxG.followBounds(0, 0, 100000, FlxG.height);
			FlxG.follow(_followBeacon, 3);
			
			_layerAction.add(_player);
			(_player.controller as PlayerController).beforeLevelStart = true;
		}
		
		private function initLevel():void
		{
			addActor(new PlaneController(_player, _layerAction), 400, 20);
			addActor(new PlaneController(_player, _layerAction), 600, 40);
			addActor(new PlaneController(_player, _layerAction), 1000, 60);
			addActor(new PlaneController(_player, _layerAction), 1400, 40);
			addActor(new PlaneController(_player, _layerAction), 1800, 20);
			
			addActor(new BuildingController(_player, _layerAction), 600, 60);
			
			FlxG.playMusic(Assets.MusicTheme, 0.5);
			
			_levelStarted = true;
			(_player.controller as PlayerController).beforeLevelStart = false;
		}
		
		private function addActor(actorController:ActorController, x:Number, y:Number):void
		{
			var theActor:Actor = new Actor(actorController, x, y);
			
			if ((actorController as PlaneController) != null)
			{
				theActor.health = Constants.PLANE_MAX_HEALTH;
				_planes.push(theActor);
			}
			
			_layerAction.add(theActor, true);
		}
		
		private var _robotVoiceTimer:Number = 0;
		private var _robotVoiceIndex:uint = 0;
		
		override public function update():void
		{
			// Debug keys!
			if (FlxG.keys.justPressed("ONE")) 	_layerFront.visible = !_layerFront.visible;
			if (FlxG.keys.justPressed("TWO")) 	_layerAction.visible = !_layerAction.visible;
			if (FlxG.keys.justPressed("THREE"))	_layerMiddle.visible = !_layerMiddle.visible;
			if (FlxG.keys.justPressed("FOUR")) 	_layerBack.visible = !_layerBack.visible;
			
			if (!_levelStarted)
			{
				if (_playingTutorial)
				{
					playTutorial();
					return;
				}
				else if (_player.x > 0)
				{
					_playingTutorial = true;
				}
			}
			
			// Voice effect!
			/*_robotVoiceTimer += FlxG.elapsed;
			if (_robotVoiceTimer > 5)
			{
				_robotVoiceTimer -= 5;
				_robotVoices[_robotVoiceIndex].play();
				_robotVoiceIndex = (_robotVoiceIndex + 1) % RANDOM_VOICEFX_COUNT;
			}*/
			
			updateLaserCombat();
			
			// HUD
			var playerController:PlayerController = (_player.controller as PlayerController);
			playerController.updateHUD(_hud);
			
			_distanceTraveled += _player.x - _previousDistance;
			_previousDistance = _player.x;
			
			var scaledDistance:Number = _distanceTraveled / 70;
			_hud.setDistance(scaledDistance.toFixed(1));
			
			collide();
			super.update();
			
			// update beacon (?)
			_followBeacon.x = _player.x + FOLLOW_OFFSET;
			_followBeacon.y = _player.y;
		}
		
		private function updateLaserCombat():void
		{
			var playerController:PlayerController = (_player.controller as PlayerController);
			if (playerController.isLaserActive())
			{
				//playerController.setLaserClip(null);
				for (var i:uint = 0; i < _planes.length; ++i)
				{
					if (_planes[i].x > FlxG.width - FlxG.scroll.x)
						continue;
					
					var enemy:Actor = _planes[i];
					
					if (playerController.checkLaserHit(enemy))
					{
						/*
						var laserRect:Rectangle = playerController.getLaserRect();
						var laserClip:Rectangle = new Rectangle(
													laserRect.x, 
													enemy.y, 
													enemy.x + (enemy.width) - laserRect.x, 
													laserRect.y + laserRect.height - enemy.y);
						playerController.setLaserClip(laserClip);
						*/
						var laserRect:Rectangle = playerController.getLaserRect();
						var laserX:Number = laserRect.x
						var laserY:Number = laserRect.y + (laserRect.height / 2);
						
						(enemy.controller as PlaneController).setSparksDirection(
								laserX, 
								laserY);
						
						enemy.hurt(Constants.LASER_PLANE_DAMAGE);
						
						if (enemy.health <= 0)
						{
							enemy.destroy();
							
							_layerAction.remove(enemy, true);
							_planes.splice(i, 1);
						}
						
						//break; // Multiple hits, laser isn´t clipped
					}
				}
			}
		}
		
		private function setupSmoke(emitter:FlxEmitter):void
		{
			emitter.setSize(6, 2);
			emitter.setRotation(0, 0);
			emitter.setXSpeed(-10, 0);
			emitter.setYSpeed(-20, -30);
			emitter.gravity = 0;
			for (var i:uint = 0; i <10; ++i)
			{
				var smoke:FlxSprite = new FlxSprite();
				if (i % 2)
				{
					smoke.loadGraphic(Assets.SpriteSmoke, true, false, 14, 12);
				}
				else
				{
					smoke.loadGraphic(Assets.SpriteSmokeBig, true, false, 28, 24);
				}
				smoke.exists = false;
				smoke.addAnimation("smoke", new Array(1, 2, 3, 4, 3, 2), 4, true);
				smoke.play("smoke");
				smoke.solid = false;
				emitter.add(smoke, true);
			}
		}
		
		private function startSmoke(emitter:FlxEmitter):void
		{
			emitter.start(false, 0.2);
		}
		
		private var _tutorialText:TutorialText = null;
		
		private function playTutorial():void
		{
			if (!_tutorialText)
			{
				_tutorialText = new TutorialText();
				add(_tutorialText);
			}
			_tutorialText.update();
			if (_tutorialText.tutorialComplete)
			{
				_tutorialText.kill();
				_playingTutorial = false;
				initLevel();
			}
		}
	}
}