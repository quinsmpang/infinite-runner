/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;

	/**
	 * Spins a reel.
	 * 
	 * @author Rob Harris
	 */
	public class BanditSpin extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** System context. */
		private var context:Object;
		
		private var spins:int;
		
		private var stop:int;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, dur:uint, spins:int, stop:int, context:Object):BanditSpin 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:BanditSpin = pool.pop();
			}
			else
			{
				anim = new BanditSpin();
			}
			// initialize the variables
			anim.context = context;
			anim.wait = wait;
			anim.dur = dur;
			anim.stime = 0;
			anim.spins = spins;
			anim.stop = stop;
			
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			context.log.info("destroy", this);
			super.destroy();
			context = null;
			
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
			context.log.info("animate", this);
//			var control:AnimControl = alist.control;
//			if (stime == 0)
//			{
//                stime = control.time;
//			}
//			if (control.time >= stime+wait)
//			{
				var slotline:int = context.animVars.getInt("slotline", 200)-alist.dob.width/2;
				var stops:int = (alist.dob.height/alist.dob.width)-3;
				var dur0:int = dur/stops;

				// make path from starting pos to wind back the reel slightly
				path = Path.make(alist, alist.dob.x, alist.dob.y-10, 0, 200);
				path.osc = true;
				path.repeat = 1;
				path.easing = Normalizer.EASE_OUT;
				path.block = true;
				
				// make path from starting pos to reset pos
				Path.make(alist, alist.dob.x, 0, 0, dur0*(-alist.dob.y/alist.dob.width)).block = true;
				
				// compute reset pos for reel
				var y0:int = alist.dob.width*3-alist.dob.height;

				// compute stop pos for reel
				var y1:int = 0-(stop*alist.dob.width)+slotline;
				
				Set.make(alist, 0, "y", y0.toString());
				
				// make path to loop from reset pos N times
				var path:Path = Path.make(alist, alist.dob.x, 0, 0, dur0*stops);
				path.repeat = spins;
				path.loop = true;
				path.block = true;
				
				Set.make(alist, 0, "y", y0.toString());
				var diff:int = -(y0-y1);
				
				// make path from reset pos to stop pos
				Path.make(alist, alist.dob.x, y1, 0, dur0*(diff/alist.dob.width)).block = true;
				
				// make path to bounce at stop point
				path = Path.make(alist, alist.dob.x, y1+10, 0, 200);
				path.osc = true;
				path.repeat = 1;
				path.easing = Normalizer.EASE_OUT;
				
				return true;
//			}
//			return false;
		}	
	}
}