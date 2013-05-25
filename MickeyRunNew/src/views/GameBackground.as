/**
 *
 * Hungry Hero Game
 * http://www.hungryherogame.com
 * 
 * Copyright (c) 2012 Hemanth Sharma (www.hsharma.com). All rights reserved.
 * 
 * This ActionScript source code is free.
 * You can redistribute and/or modify it in accordance with the
 * terms of the accompanying Simplified BSD License Agreement.
 *  
 */

package views {

	import citrus.objects.CitrusSprite;
	
	import starling.display.Sprite;
	
	/**
	 * This class defines the whole InGame background containing multiple background layers.
	 *  
	 * @author hsharma
	 * 
	 */
	public class GameBackground extends CitrusSprite
	{
		/**
		 * Different layers of the background. 
		 */
		 
		 private var _container:Sprite;
		
		private var bgLayer1:BgLayer;
		private var bgLayer2:BgLayer;
		private var bgLayer3:BgLayer;
		private var bgLayer4:BgLayer;
		
		/** Current speed of animation of the background. */
		public var speed:Number = 100;
		
		/** State of the game. */		
		public var state:int;
		
		/** Game paused? */
		public var gamePaused:Boolean = false;
		
		private var _hero:MickeyHero;
		
		private var _backGround:Boolean = true;
		
		private var _context:GameContext;
		
		public function GameBackground(name:String, params:Object = null, 
									   _hero:MickeyHero=null, backGround:Boolean=true, context:GameContext=null )
		{
			this._context = context;
			super(name, params);
			
//			this.parallax = 1;
			
			_container = new Sprite();
			
			_container.touchable = false;
			
			_view = _container;
			
			this._backGround = backGround;
			
			this._hero = _hero;
			
			if ( backGround ) {
				bgLayer1 = new BgLayer(1);
				bgLayer1.parallaxDepth = 0.02;
				_container.addChild(bgLayer1);
				
//				bgLayer2 = new BgLayer(2);
//				bgLayer2.parallaxDepth = 0.2;
//				_container.addChild(bgLayer2);
				
//				bgLayer3 = new BgLayer(3);
//				bgLayer3.parallaxDepth = 0.25;
//				_container.addChild(bgLayer3);
			
			} else {
			
				bgLayer4 = new BgLayer(4);
				bgLayer4.parallaxDepth = 0.9;
				_container.addChild(bgLayer4);
				
			}
			
			//_container.flatten();
			
		}
		
		private var offsetX:int = 0;
		public function setHero( _hero:MickeyHero ):void {
			this._hero = _hero;
			
			offsetX = _hero.x;
			speed = 20;
		}
		
		/**
		 * On every frame, animate each layer based on its parallax depth and hero's speed. 
		 * @param event
		 * 
		 */
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if (!gamePaused)
			{
//				if ( _hero != null ) 
//					this.x = _hero.x - offsetX;
				
				if ( _context.viewCamPos == null ) {
//					this.x = _ce.state.view.camera.camPos.x - 100;
//					this.y = _ce.state.view.camera.camPos.y - 100;
				} else {
//					this.x = _context.viewCamLeftX - 100;
//					this.y = _context.viewCamPos.y - 100;
				}
				
				speed = _hero.velocityX / 20;
				
				if ( _backGround ) {
				
					// Background 1 - Sky
//					bgLayer1.x -= Math.ceil(speed * bgLayer1.parallaxDepth);
					// Hero flying left
	//				if (bgLayer1.x > 0) bgLayer1.x = -_ce.stage.stageWidth;
					// Hero flying right
//					if (bgLayer1.x < -_ce.stage.stageWidth ) bgLayer1.x = 0;
					
					//bgLayer1.y = 0;
					
	//				// Background 2 - Hills
//					bgLayer2.x -= Math.ceil(speed * bgLayer2.parallaxDepth);
					// Hero flying right
//					if (bgLayer2.x < -_ce.stage.stageWidth * 1.3 ) bgLayer2.x = 0;
	//				
	//				// Background 3 - Buildings
//					bgLayer3.x -= Math.ceil(speed * bgLayer3.parallaxDepth);
	//				// Hero flying left
	//				if (bgLayer3.x > 0) bgLayer3.x = -_ce.stage.stageWidth;
	//				// Hero flying right
//					if (bgLayer3.x < -_ce.stage.stageWidth * 1.3) bgLayer3.x = 0;
				
				} else {
	//				// Background 4 - Trees
					bgLayer4.x -= Math.ceil(speed * bgLayer4.parallaxDepth);
	//				// Hero flying left
	//				if (bgLayer4.x > 0) bgLayer4.x = -_ce.stage.stageWidth;
	//				// Hero flying right
					if (bgLayer4.x < -_ce.stage.stageWidth ) bgLayer4.x = 0;
				}
			}
		}
	}
}