/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;
    import com.playdom.gas.SpecialEffect;
    import com.playdom.common.recycle.RecyclableBitmap;
    
    import flash.display.Bitmap;
    import flash.display.DisplayObjectContainer;

	/**
	 * Plays a SpecialEffect object over time.
	 * 
	 * @author Rob Harris
	 */
	public class Player extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var effect:SpecialEffect;
		private var lag:int;
		private var bmp:Bitmap;
		
        /**
         * Creates or reuses an instance of this class.
         *   
		 * @param alist  The anim list.
		 * @param wait   The number of milliseconds to wait before starting.
		 * @param effect The special effect object.
		 * @param lag    The number of frames to lag behind the active frame (0 indicates the effect master)
		 * 
		 * @return An instance of this class
		 */
        public static function make(alist:AnimList, wait:int, effect:SpecialEffect, lag:int):Player 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Player = pool.pop();
			}
			else
			{
				anim = new Player();
			}
			// initialize the variables
			anim.wait = wait;
			anim.effect = effect;
			anim.lag = lag;
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   

		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			super.destroy();
			effect = null;
			if (pool.indexOf(this) == -1) 
			{
				pool.push(this);
			}
		}	
		
		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the animation has completed. 
		 */
		override public function animate():Boolean
		{
			if (stime == 0) 
			{
				stime = alist.control.time;
				if (alist.dob is Bitmap)
				{
					bmp = Bitmap(alist.dob);
				}
				else if(alist.dob is DisplayObjectContainer)
				{
					bmp = Bitmap(DisplayObjectContainer(alist.dob).getChildAt(0));
				}
			}
			if (alist.control.time >= stime+wait) 
			{
				if (lag == 0)
				{
					effect.animate();
				}
				else
				{
					bmp.bitmapData = effect.getFrame(lag);
				}
			}
			return false;
		}
		
		/**
		 * Parses tokenized data to create an instance of this object.
		 *  
		 * @param tokenizer The script tokenizer.
		 * @param helper    The parser helper.
		 * @param context   The system context.
		 */
		public static function parse( tokenizer:Object, helper:Object, context:Object ):void
		{
			var effect:SpecialEffect = context.effects[tokenizer.getString("effect", "")];
			if (effect)
			{
				var bmp:Bitmap = effect;
				var lag:int = tokenizer.getInt("lag", 0);
				if (lag == 0)
				{
					//									objLayer.addChild(effect);
				}
				else
				{
					bmp = RecyclableBitmap.make(null, helper.objLayer, context.assetHash);
					bmp.bitmapData = effect.getFrame(0);
				}
				helper.objLayer.addChild(bmp);
				// add the player anim
				helper.alist = context.animControl.attachAnimList(bmp);
				Player.make(helper.alist, 0, effect, lag);
				helper.parseDobAttributes( bmp, tokenizer );
				helper.alist = null;
			}
			tokenizer.destroy();
		}
		
		public static function makePlayer(name:String, x:int, y:int, lag:int, context:Object):void
		{
			var effect:SpecialEffect = context.effects[name];
			if (effect)
			{
				var bmp:Bitmap = effect;
				if (lag == 0)
				{
					context.playfieldLayer.addChild(effect);
				}
				else
				{
					bmp = RecyclableBitmap.make(null, context.playfieldLayer, context.assetHash);
					bmp.bitmapData = effect.getFrame(0);
				}
				//								context.playfieldLayer.addChild(bmp);
				// add the player anim
				var alist:AnimList = context.animControl.attachAnimList(bmp);
				Player.make(alist, 0, effect, lag);
			}
		}
		
	}
}