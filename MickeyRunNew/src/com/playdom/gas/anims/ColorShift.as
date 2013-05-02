/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
 	import com.playdom.gas.AnimList;
 	
 	import flash.display.DisplayObject;
 	import flash.display.Sprite;
 	import flash.text.TextField;
 	
	/**
	 * Alters the color of a text or shape display object over time.
	 * 
	 * @author Rob Harris
	 */
	public class ColorShift extends Normalizer	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Starting color. */
		private var start:uint;
				
		/** Ending color. */
		private var end:uint;

		/** Set if display object is a text field. */
		private var target:Object;
		
		private var colorProp:String;
		
        /**
         * Creates or reuses an instance of ColorShifter.
         * 
         * @param start  The starting color.
         * @param end    The ending color.
         * @param dur    The animation duration (in milliseconds).
         *   
         * @return  A ColorShifter object. 
         */
        public static function make(alist:AnimList, start:Number, end:Number, wait:int, dur:int):ColorShift 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:ColorShift = pool.pop();
			}
			else
			{
				anim = new ColorShift();
			}
			// initialize the variables
			anim.initNorm(wait, dur);
			anim.start = start;
			anim.end = end;
			
			if (alist.dob is Sprite) 
			{
				if (alist.dob.hasOwnProperty("color")) 
				{
					anim.target = alist.dob;
					anim.colorProp = "color";
				}
				else
				{
					var spr:Sprite = alist.dob as Sprite;
					var child:DisplayObject = spr.numChildren > 0 ? spr.getChildAt(0) : null;
					if (child != null)
					{
						if (child is TextField) 
						{
							anim.target = child;
							anim.colorProp = "textColor";
						}
						else if (child.hasOwnProperty("color")) 
						{
							anim.target = child;
							anim.colorProp = "color";
						}
					}
				}
			}
			else if (alist.dob is TextField)
			{
				anim.target = alist.dob;
				anim.colorProp = "textColor";
			}
			else if (alist.dob.hasOwnProperty("color")) 
			{
				anim.target = alist.dob;
				anim.colorProp = "color";
			}
			
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
			target = null;
			colorProp = null;
			if (pool.indexOf(this) == -1) 
			{
				pool.push(this);
			}
		}	
						
		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the fade is complete. 
		 */
		override public function animate():Boolean 
		{
			var done:Boolean = super.animate();
			var r1:uint = (start >> 16)&0xff; 
			var g1:uint = (start >> 8)&0xff; 
			var b1:uint = start&0xff;
			var r2:uint = (end >> 16)&0xff; 
			var g2:uint = (end >> 8)&0xff; 
			var b2:uint = end&0xff;
			var p2:Number = 1-control;
			r1 = r1*p2+r2*control;
			g1 = g1*p2+g2*control;
			b1 = b1*p2+b2*control;
			var rgb:uint = (r1 << 16)|(g1 << 8)|b1; 
			if (target != null) 
			{
				target[colorProp] = rgb;
			}
			return done;
		}		
    
        /** Swaps the starting and ending values. */
        override protected function swapEnds():void 
		{
            super.swapEnds();
            var tmp:Number = start;
            start = end;
            end = tmp;
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
			var anim:Normalizer = ColorShift.make(helper.alist,
				tokenizer.getHex("start", 0xff0000),
				tokenizer.getHex("end", 0x0000ff),
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1000)
			);
			helper.parseEasingAttribute(anim, tokenizer);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}