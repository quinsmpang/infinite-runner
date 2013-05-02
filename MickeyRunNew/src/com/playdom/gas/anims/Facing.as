/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    import com.playdom.gas.interfaces.IHflip;

	/**
	 * Horizontally flips a display object to face the direction it is travelling.
	 * 
	 * @author Rob Harris
	 */
	public class Facing extends AnimBase implements IHflip
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var end_time:uint;
		
		private var last_x:int;
		
		private var facingLeft:Boolean;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, dur:uint):Facing 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Facing = pool.pop();
			}
			else
			{
				anim = new Facing();
			}
			// initialize the variables
			anim.wait = wait;
			anim.dur = dur;
			anim.stime = 0;
			
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
				facingLeft = false;
			}
			if (control.time >= stime+wait)
			{
				var diff:int = last_x - alist.dob.x;
				if (diff > 0)
				{
					if (facingLeft)
					{
						facingLeft = false;
						alist.hflip();
					}
				}
				else if (diff < 0)
				{
					if (!facingLeft)
					{
						facingLeft = true;
						alist.hflip();
					}
				}
				last_x = alist.dob.x;
				return end_time < control.time;
			}
			return false;
		}	
		
		public function hflip():void
		{
			alist.dob.scaleX = -alist.dob.scaleX;
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
				tokenizer.getInt("dur", 0)
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}