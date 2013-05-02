/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    import com.playdom.common.recycle.RecyclableBlur;
    import com.playdom.common.util.NumberUtils;

	/**
	 * Blurs the display object based on change in location.
	 * 
	 * @author Rob Harris
	 */
	public class MotionBlur extends AnimBase
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var end_time:uint;
		
		private var last_x:int;
		
		private var last_y:int;
		
		private var div:Number;
		
		private var last_blur:Number;
		
		private var max:int;
		
		/** Array wrapper for filter. */
		private var arrayWrapper:Array;
		
		/** Blur filter. */
		private var blurFilter:RecyclableBlur;

		/**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, dur:uint, div:Number, max:int):MotionBlur 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:MotionBlur = pool.pop();
			}
			else
			{
				anim = new MotionBlur();
			}
			// initialize the variables
			anim.div = div == 0 ? 1 : div;
			anim.max = max;
			anim.wait = wait;
			anim.dur = dur;
			anim.stime = 0;
			anim.last_blur = 0;
			
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			if (alist.dob)
			{
				alist.dob.filters = null;
			}
			super.destroy();
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
			var control:AnimControl = alist.control;
			if (stime == 0)
			{
                stime = control.time;
	            end_time = dur == 0 ? int.MAX_VALUE : dur+control.time+wait;
				last_x = alist.dob.x;
				last_y = alist.dob.y;
			}
			if (control.time >= stime+wait)
			{
				var diff:int = NumberUtils.calcDist(last_x, last_y,alist.dob.x, alist.dob.y);

				if (arrayWrapper == null)
				{
					blurFilter = RecyclableBlur.make();
					arrayWrapper = blurFilter.array;
				}
				var blur:Number = Math.min(max, diff/div);
				if (blur != last_blur)
				{
					blurFilter.setBlur(blur);
					alist.dob.filters = arrayWrapper;			
					last_blur = blur;
				}
				last_x = alist.dob.x;
				last_y = alist.dob.y;
				
				return end_time < control.time;
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
			var anim:AnimBase = make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 0),
				tokenizer.getNumber("div", 1),
				tokenizer.getInt("max", 10)
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}