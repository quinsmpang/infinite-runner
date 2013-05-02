/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.common.util.ViewUtils;
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    
    import flash.geom.Rectangle;

	/**
	 * Moves a display object over time.
	 *
     * @see AnimList#makeAnimList() 
     * @see AnimFactory#makeMotion() 
	 * 
	 * @author Rob Harris
	 */
	public class Move extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
        /** Multiplier for degrees to radian calculation */
        private static const DEG_TO_RAD:Number = Math.PI/180;
        
        /** Multiplier for radian to degrees calculation */
        private static const RAD_TO_DEG:Number = 180/Math.PI;
        
        private static const GRAV:int = 32*32;
		
        private var x_acc:Number = 0;
        private var y_acc:Number = 0;
        private var x_vel:Number = 0;
        private var y_vel:Number = 0;
        private var last_time:uint;
        private var end_time:uint;

		private var ymin:int = int.MIN_VALUE;
		private var ymax:int = int.MAX_VALUE;
		private var _boundingBox:Rectangle;
		
        /**
         * Creates or reuses an instance of Motion.
         *   
         * @return  A Motion object. 
         */
        public static function make(alist:AnimList, wait:int, dur:uint, spd:Number, dir:Number, xacc:Number=0, yacc:Number=0, _boundingBox:Rectangle = null):Move 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Move = pool.pop();
			}
			else
			{
				anim = new Move();
			}
			// initialize the variables
			anim.wait = wait;
			anim.dur = dur;
			anim.stime = 0;
			anim.setVelocity(spd, dir);
			anim.setAcceleration(xacc, yacc);
			anim._boundingBox = _boundingBox;
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
		
		/**
		 * Sets the X and Y acceleration values.
		 *  
		 * @param x  The X acceleration (pixels per second).
		 * @param y  The Y acceleration (pixels per second).
		 */
        public function setAcceleration(x:Number,y:Number):void 
		{
            x_acc = x;
            y_acc = y;
        }
        
		/**
		 * Sets the speed and direction.
		 *  
		 * @param spd The movement speed (pixels per second).
		 * @param dir The movement direction (0 is to the left, 90 is down, etc.)
		 */
        public function setVelocity(spd:Number,dir:Number):void 
        {
            x_vel = Math.cos(dir*DEG_TO_RAD)*spd;
            y_vel = Math.sin(dir*DEG_TO_RAD)*spd;
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
		
		private var dirtyLoc:Boolean;
                						
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
	            last_time = control.time+wait;
				dirtyLoc = true;
	            end_time = dur == 0 ? int.MAX_VALUE : dur+control.time+wait;
			}
			if (control.time >= stime+wait)
			{
				if (dirtyLoc)
				{
					dirtyLoc = false;
					alist.x_loc = alist.dob.x;
					alist.y_loc = alist.dob.y;
				}
	            var dt:int = control.time-last_time;
	            last_time = control.time;
	            x_vel += x_acc*dt/1000;
	            y_vel += y_acc*dt/1000;
				alist.x_loc += x_vel*dt/1000;
				alist.y_loc += y_vel*dt/1000;
				alist.x_loc = Math.round(alist.x_loc);
				alist.y_loc = Math.round(alist.y_loc);
				if( _boundingBox && !ViewUtils.chechBoundingBox(_boundingBox, alist.x_loc, alist.y_loc))
				{
					return true;
				}
				else
				{
					alist.dob.x = alist.x_loc;
	            	alist.dob.y = alist.y_loc;
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
				tokenizer.getNumber("spd", 100),
				tokenizer.getNumber("dir", 0),
				tokenizer.getNumber("xacc", 0),
				tokenizer.getNumber("yacc", 0)
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}