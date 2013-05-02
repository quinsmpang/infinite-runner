/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;

	/**
	 * Positions the display object.
	 * 
	 * @author Rob Harris
	 */
	public class Pos extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var x:int;
		private var y:int;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, x:int, y:int):Pos 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Pos = pool.pop();
			}
			else
			{
				anim = new Pos();
			}
			// initialize the variables
			anim.wait = wait;
			anim.x = x;
			anim.y = y;
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
			}
			if (control.time >= stime+wait)
			{
				alist.dob.x = x;
				alist.dob.y = y;
				return true;
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
			var anim:Pos = Pos.make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("x", 0),
				tokenizer.getInt("y", 0)
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}