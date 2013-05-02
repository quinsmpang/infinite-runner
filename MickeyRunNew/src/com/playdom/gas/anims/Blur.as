/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;
    import com.playdom.common.recycle.RecyclableBlur;

	/**
	 * Alters the blur factor of a display object over time.
	 * 
	 * @example The following code fades in the display object during a 5 second period:  <listing version="3.0">
	 *  
	 * var dob:DisplayObject = new Bitmap(myImage);     // sample display object
	 * dob.visible = false;                             // make it invisible
	 * var alist:AnimList = AnimList.makeAnimList(dob); // create an AnimList; attach it to the display object and the animation system
	 * Blurer.make(alist, 0, 1, 5000);        // fade in during 5 secs
	 * 
     * </listing> 
     * @see AnimList#makeAnimList() 
	 * 
	 * @author Rob Harris
	 */
	public class Blur extends Normalizer	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Starting alpha value. */
		private var start:Number;
				
		/** Ending alpha value. */
		private var end:Number;
		
		/** Array wrapper for filter. */
		private var arrayWrapper:Array;

		/** Blur filter. */
		private var blurFilter:RecyclableBlur;
		
        /**
         * Creates or reuses an instance of Blurer.
         * 
         * @param start  The starting alpha value.
         * @param end    The ending alpha value.
         * @param dur    The animation duration (in milliseconds).
         *   
         * @return  A Blurer object. 
         */
        public static function make(alist:AnimList, start:Number, end:Number, wait:int, dur:int):Blur 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Blur = pool.pop();
			}
			else
			{
				anim = new Blur();
			}
			// initialize the variables
			anim.initNorm(wait, dur);
			anim.start = start;
			anim.end = end;
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
						
		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the fade is complete. 
		 */
		override public function animate():Boolean 
		{
			var done:Boolean = super.animate();
			
			if (arrayWrapper == null)
			{
				blurFilter = RecyclableBlur.make();
				arrayWrapper = blurFilter.array;
			}
			var blur:Number = start+((end-start)*control);
			if (blur > 0)
			{
				blurFilter.setBlur(blur);
				alist.dob.filters = arrayWrapper;			
			}
			else
			{
				alist.dob.filters = null;			
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
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			super.destroy();
			arrayWrapper = null;
			if (blurFilter)
			{
				blurFilter.destroy();
				blurFilter = null;
			}
			if (pool.indexOf(this) == -1) 
			{
				pool.push(this);
			}
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
			var anim:Normalizer = Blur.make(helper.alist,
				tokenizer.getNumber("start", 1),
				tokenizer.getNumber("end", 0),
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1000)
			);
			helper.parseEasingAttribute(anim, tokenizer);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}