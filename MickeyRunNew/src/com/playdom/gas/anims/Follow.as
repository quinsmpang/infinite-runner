/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.common.util.FindChild;
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;

	/**
	 * Moves a display object to follow a target object.
	 * 
	 * @author Rob Harris
	 */
	public class Follow extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var cursor:Boolean;
		
		private var lag:Boolean;
		
		private var end_time:uint;
		
		private var targetDob:DisplayObject;
		
		private var target:Object;
		
		private var topLayer:Sprite;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, dur:uint, target:Object, topLayer:Sprite, lag:Boolean):Follow 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Follow = pool.pop();
			}
			else
			{
				anim = new Follow();
			}
			// initialize the variables
			anim.wait = wait;
			anim.dur = dur;
			anim.stime = 0;
			anim.target = target;
			anim.topLayer = topLayer;
			anim.lag = lag;
			
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
		
		/**
		 * Finds the target object.
		 */
		private function findTarget():void 
		{
			cursor = target == "cursor";
			if (!cursor)
			{
				if (target is String)
				{
					targetDob = FindChild.byName(target as String, topLayer);
				}
				else if ( target is DisplayObject )
				{
					targetDob = target as DisplayObject;
				}
			}
		}	
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			super.destroy();
			target = null;
			targetDob = null;
			topLayer = null;
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
				findTarget();
			}
			if (control.time >= stime+wait)
			{
				if (cursor)
				{
	            	var x1:int = alist.dob.parent.mouseX;
	            	var y1:int = alist.dob.parent.mouseY;
				}
				else if (targetDob)
				{
					x1 = targetDob.x;
					y1 = targetDob.y;
				}
				if (lag)
				{
					alist.dob.x = (x1+alist.dob.x)/2;
					alist.dob.y = (y1+alist.dob.y)/2;
				}
				else
				{
					alist.dob.x = x1;
					alist.dob.y = y1;
				}
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
				tokenizer.getString("target", "cursor"), 
				helper.objLayer as Sprite,
				tokenizer.getBoolean("seek", false)
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}