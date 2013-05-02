/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;

	/**
	 * Alters the scale values of a display object over time.
	 * 
	 * @author Rob Harris
	 */
	public class Scale extends Normalizer	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Starting alpha value. */
		private var start:Number;
				
		/** Ending alpha value. */
		private var end:Number;

		/** True to scale horizontally. */
        private var horiz:Boolean;
		
		/** True to scale vertically. */
        private var vert:Boolean;
		
        /**
         * Creates or reuses an instance of Scaler.
         * 
         * @param start  The starting scale.
         * @param end    The ending scale.
         * @param dur    The animation duration (in milliseconds).
         *   
         * @return  A Scaler object. 
         */
        public static function make(alist:AnimList, start:Number, end:Number, wait:int, dur:int, horiz:Boolean=true, vert:Boolean=true):Scale 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Scale = pool.pop();
			}
			else
			{
				anim = new Scale();
			}
			// initialize the variables
			anim.initNorm(wait, dur);
			anim.start = start;
			anim.end = end;
			anim.horiz = horiz;
			anim.vert = vert;
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
			if (started)
			{
	            var scale:Number = start+((end-start)*control);
	            if (vert) {
	                alist.dob.scaleY = scale;
	            }
	            if (horiz) {
	                alist.dob.scaleX = scale;
	            }			
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
			var scaler:Scale = make( helper.alist,
				tokenizer.getNumber("start", 1),
				tokenizer.getNumber("end", 0),
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1000),
				tokenizer.getBoolean("horiz", true),
				tokenizer.getBoolean("vert", true)
			);
			helper.parseEasingAttribute(scaler, tokenizer);
			helper.parseAnimAttributes(scaler, tokenizer);
			tokenizer.destroy();
		}
		
	}
}