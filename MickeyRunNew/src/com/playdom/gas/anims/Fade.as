/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;

	/**
	 * Alters the alpha value of a display object over time.
	 * 
	 * @author Rob Harris
	 */
	public class Fade extends Normalizer	
	{
		/** The recycling pool */
		private static var pool:Array = [];
			
		/** Starting alpha value. */
		private var start:Number;
				
		/** Ending alpha value. */
		private var end:Number;
		
        /**
         * Creates or reuses an instance of Fader.
         * 
         * @param start  The starting alpha value.
         * @param end    The ending alpha value.
		 * @param wait   The number of milliseconds to wait before starting.
		 * @param dur    The number of milliseconds for the duration of the activity.
         *   
         * @return  A Fader object. 
         */
        public static function make(alist:AnimList, start:Number, end:Number, wait:int, dur:int):Fade 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Fade = pool.pop();
			}
			else
			{
				anim = new Fade();
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
			alist.dob.alpha = start+((end-start)*control);
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
			var fader:Fade = make(helper.alist,
				tokenizer.getNumber("start", 1),
				tokenizer.getNumber("end", 0),
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1000)
			);
			helper.parseEasingAttribute(fader, tokenizer);
			helper.parseAnimAttributes(fader, tokenizer);
			tokenizer.destroy();
		}
		
	}
}