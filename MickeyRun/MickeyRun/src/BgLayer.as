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

package {

	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * This class defines each of background layers used in the InGame screen.
	 *  
	 * @author hsharma
	 * 
	 */
	public class BgLayer extends Sprite
	{
		/** Layer identification. */
		private var _layer:int;
		
		/** Primary image. */
		private var image1:Image;
		
		/** Secondary image. */
		private var image2:Image;
		
		/** Parallax depth - used to decide speed of the animation. */
		public var parallaxDepth:Number;
		
		[Embed(source="/../embed/bgMountains.png")]
		private var bgMountains:Class;
		
		[Embed(source="/../embed/bgBushes.png")]
		private var bgBushes:Class;
		
		[Embed(source="/../embed/bgForegroundBush.png")]
		private var bgForegroundBush:Class;
		
		public function BgLayer(_layer:int)
		{
			super();
			
			this._layer = _layer;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * On added to stage. 
		 * @param event
		 * 
		 */
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			if (_layer == 1)
			{
//				image1 = new Image(Texture.fromBitmap(new bgLayer()));
//				image1.blendMode = BlendMode.NONE;
//				image2 = new Image(Texture.fromBitmap(new bgLayer()));
//				image2.blendMode = BlendMode.NONE;
				
				image1 = new Image(Assets.getTexture("BgLayer" + _layer));
				image1.blendMode = BlendMode.NONE;
				image1.touchable = false;
				image1.scaleX = image1.scaleY = 1.5;
				image1.x = image1.y = 0;
//				image2 = new Image(Assets.getTexture("BgLayer" + _layer));
//				image2.blendMode = BlendMode.NONE;
//				image2.touchable = false;
				
			}
			else if (_layer == 2) {
				image1 = new Image(Texture.fromBitmap(new bgMountains()));
				//image1.blendMode = BlendMode.NONE;
				image2 = new Image(Texture.fromBitmap(new bgMountains()));
				//image2.blendMode = BlendMode.NONE;	
			}
			else if (_layer == 3) {
				image1 = new Image(Texture.fromBitmap(new bgBushes()));
				//image1.blendMode = BlendMode.NONE;
				image2 = new Image(Texture.fromBitmap(new bgBushes()));
				//image2.blendMode = BlendMode.NONE;	
			}
			else if (_layer == 4) {
				image1 = new Image(Texture.fromBitmap(new bgForegroundBush()));
				//image1.blendMode = BlendMode.NONE;
				image2 = new Image(Texture.fromBitmap(new bgForegroundBush()));
				//image2.blendMode = BlendMode.NONE;	
			}
			else
			{
				image1 = new Image(Assets.getAtlas().getTexture("bgLayer" + _layer));
				image2 = new Image(Assets.getAtlas().getTexture("bgLayer" + _layer));
			}
			
			image1.x = 0;
			image1.y = 0;//stage.stageHeight - image1.height;
			
			this.addChild(image1);
			
			if ( _layer == 1 ) return;
			
			image2.x = image2.width;
			image2.y = image1.y;
			

			this.addChild(image2);
		}
	}
}