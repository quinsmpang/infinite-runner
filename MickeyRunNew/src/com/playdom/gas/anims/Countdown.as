/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;
    
    import flash.text.TextField;

	/**
	 * Counts down time by displaying minutes and seconds.
	 * 
	 * @author Rob Harris
	 */
	public class Countdown extends AnimBase
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var start:int;
		private var end:int;
		
		private var inc:int;
		
		private var max:int;
		
        /**
         * Creates or reuses an instance of this class.
         *  
		 * @param alist      The parent anim list.
         * @param wait       The initial delay.
		 * @param type       The type of dispatch (TYPE_EVENT, TYPE_STATE, TYPE_SETTING).
         * @param key        The property key ("visible", "event").
         * @param value      The property value.
		 * @param context    The system context (gameState, config, dispatcher)
		 * 
		 * @return An instance of this class. 
		 */
		public static function make(alist:AnimList, start:int, end:int, wait:int, dur:int):Countdown 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Countdown = pool.pop();
			}
			else
			{
				anim = new Countdown();
			}
			
			// initialize the variables
			anim.wait = wait;
			anim.start = start;
			anim.end = end;
			anim.dur = dur;
			anim.stime = 0;
			anim._currSecs = 0;
			
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
		
		private var _currSecs:int;
						
		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the animation has completed. 
		 */
		override public function animate():Boolean 
		{
			if (stime == 0) 
			{	// first time this method is called
				stime = alist.control.time;
			}
			if (alist.control.time >= stime+wait) 
			{	// past wait period
				var range:int = ( start - end );
				var secs:int = alist.control.time - stime - wait;
				secs = range - secs / 1000;
				if ( secs != _currSecs )
				{
					_currSecs = secs;
					TextField( alist.dob ).text = Math.max( end, _currSecs ).toString();
				}
				return secs < end;
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
			var anim:Countdown = make(helper.alist,
				tokenizer.getInt("start", 30),
				tokenizer.getInt("end", 0),
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 3000)
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}