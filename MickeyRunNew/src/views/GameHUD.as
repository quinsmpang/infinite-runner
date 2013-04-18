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

package views  {

	import citrus.objects.CitrusSprite;
	
	import objects.CustomCoin;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * This class handles the Heads Up Display for the game.
	 *  
	 * @author hsharma
	 * 
	 */
	public class GameHUD extends Sprite
	{
		/** Lives left. */
		private var _lives:int;
		
		/** Distance travelled. */
		private var _distance:int;
		
		/** Food items score. */
		private var _foodScore:int;
		
		/** Lives icon.  */		
		private var livesLabel:TextField;
		
		/** Lives TextField. */		
		private var livesText:TextField;
		
		/** Distance icon. */		
		private var distanceLabel:TextField;
		
		/** Distance TextField. */		
		private var distanceText:TextField;
		
		/** Food Score icon. */
		private var foodScoreLabel:TextField;
		
		/** Food Score TextField. */		
		private var foodScoreText:TextField;
		
		/** Font for score label. */		
		private var fontScoreLabel:Font;
		
		/** Font for score value. */		
		private var fontScoreValue:Font;
		
		private var _context:GameContext;
		
		private var stars:Array = [];
		private var starColorTexture:Texture;
		private var starBWTexture:Texture;
		
		public function GameHUD( context:GameContext )
		{
			this._context = context;
			super();
			
			starColorTexture = Assets.getMiscAtlas().getTexture( "star2" );
			starBWTexture = Assets.getMiscAtlas().getTexture( "star2bw" );
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			this.addEventListener(TouchEvent.TOUCH, onScreenTouched);
		}
		
		private function createStar( i:int, color:Boolean=false ):Image
		{
			stars[i] = new Image( color ? starColorTexture : starBWTexture );
			var image:Image = stars[ i ] as Image;
			
			image.x = 20 + i * 60;
			image.y = 20;
			image.width = 50;
			image.height = 47;
			
			this.addChild( image );
			return image;
		}
		
		public function setStars( numStars:int ):void
		{
			var image:Image;
			for (var i:int = 0; i < stars.length; i++) 
			{
				image = stars[ i ] as Image;
				if ( image ) {
					image.texture = ( i <= numStars - 1 ) ? starColorTexture : starBWTexture;
				}
			}
		}
		
		private function onScreenTouched( event:TouchEvent ):void
		{
			
		}
		/**
		 * On added to stage. 
		 * @param event
		 * 
		 */
		private function onAddedToStage(event:Event):void
		{
			createStar( 0 );
			createStar( 1 );
			createStar( 2 );
			
//			setStars( 2 );
			
			// Get fonts for score labels and values.
//			fontScoreLabel = Fonts.getFont("ScoreLabel");
//			fontScoreValue = Fonts.getFont("ScoreValue");
			
//			// Lives label
//			livesLabel = new TextField(150, 20, "L I V E S", fontScoreLabel.fontName, fontScoreLabel.fontSize, 0xffffff);
//			livesLabel.hAlign = HAlign.RIGHT;
//			livesLabel.vAlign = VAlign.TOP;
//
//			livesLabel.x = 150;
//			livesLabel.y = 5;
//			this.addChild(livesLabel);
//			
//			// Lives
//			livesText = new TextField(150, 75, "5", fontScoreValue.fontName, fontScoreValue.fontSize, 0xffffff);
//			livesText.hAlign = HAlign.RIGHT;
//			livesText.vAlign = VAlign.TOP;
//			livesText.width = livesLabel.width;
//
//			livesText.x = int(livesLabel.x + livesLabel.width - livesText.width);
//			livesText.y = livesLabel.y + livesLabel.height;
//			this.addChild(livesText);
			
//			// Distance label
//			distanceLabel = new TextField(150, 20, "S C O R E", fontScoreLabel.fontName, fontScoreLabel.fontSize, 0xffffff);
//			distanceLabel.hAlign = HAlign.RIGHT;
//			distanceLabel.vAlign = VAlign.TOP;
//
//			distanceLabel.x = int(stage.stageWidth - distanceLabel.width - 10);
//			distanceLabel.y = 5;
//			this.addChild(distanceLabel);
//			
//			// Distance
//			distanceText = new TextField(150, 75, "0", fontScoreValue.fontName, fontScoreValue.fontSize, 0xffffff);
//			distanceText.hAlign = HAlign.RIGHT;
//			distanceText.vAlign = VAlign.TOP;
//			distanceText.width = distanceLabel.width;
//			
//			distanceText.x = int(distanceLabel.x + distanceLabel.width - distanceText.width);
//			distanceText.y = distanceLabel.y + distanceLabel.height;
//			this.addChild(distanceText);
//			
//			// Score label
//			foodScoreLabel = new TextField(150, 20, "C O I N S", fontScoreLabel.fontName, fontScoreLabel.fontSize, 0xffffff);
//			foodScoreLabel.hAlign = HAlign.RIGHT;
//			foodScoreLabel.vAlign = VAlign.TOP;
//
//			foodScoreLabel.x = int(distanceLabel.x - foodScoreLabel.width - 50);
//			foodScoreLabel.y = 5;
//			this.addChild(foodScoreLabel);
//			
//			// Score
//			foodScoreText = new TextField(150, 75, "0", fontScoreValue.fontName, fontScoreValue.fontSize, 0xffffff);
//			foodScoreText.hAlign = HAlign.RIGHT;
//			foodScoreText.vAlign = VAlign.TOP;
//			foodScoreText.width = foodScoreLabel.width;
//			
//			foodScoreText.x = int(foodScoreLabel.x + foodScoreLabel.width - foodScoreText.width);
//			foodScoreText.y = foodScoreLabel.y + foodScoreLabel.height;
//			this.addChild(foodScoreText);
		}

		/**
		 * Lives left. 
		 * @return 
		 * 
		 */
//		public function get lives():int { return _lives; }
//		public function set lives(value:int):void
//		{
//			_lives = value;
//			livesText.text = _lives.toString();
//		}

		/**
		 * Distance travelled. 
		 * @return 
		 * 
		 */
		public function get distance():int { return _distance; }
		public function set distance(value:int):void
		{
			_distance = value;
//			distanceText.text = _distance.toString();
		}

		/**
		 * Food items score. 
		 * @return 
		 * 
		 */
		public function get foodScore():int { return _foodScore; }
		public function set foodScore(value:int):void
		{
			_foodScore = value;
//			foodScoreText.text = _foodScore.toString();
		}
		
		/**
		 * Add leading zeros to the score numbers. 
		 * @param value
		 * @return 
		 * 
		 */
		private function addZeros(value:int):String {
			var ret:String = String(value);
			while (ret.length < 7) {
				ret = "0" + ret;
			}
			return ret;
		}
	}
}