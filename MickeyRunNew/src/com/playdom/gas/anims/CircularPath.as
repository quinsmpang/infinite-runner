/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;
    import com.playdom.common.util.NumberUtils;

	/**
	 * Moves the display object along a bezier curve from its current location to a new location.
	 * 
	 * @example The following code moves the display object to 100,200 during a 2.5 second period:  <listing version="3.0">
	 *  
	 * var dob:DisplayObject = new Bitmap(myImage);     // sample display object
	 * var alist:AnimList = AnimList.makeAnimList(dob); // create an AnimList; attach it to the display object and the animation system
	 * AnimFactory.makePath(alist, 100, 200, 2500);     // move to 100,200 during 2.5 secs
	 * 
     * </listing> 
     * @see AnimList#makeAnimList() 
     * @see AnimFactory#makePath() 
	 * 
	 * @author Rob Harris
   	 */
	public class CircularPath extends Path	
	{
		/** Called when the path is started. */
		public var startListener:Function;
		
		/** The recycling pool */
		private static var bpool:Array = [];
		
		private var ccw:Boolean = false;
		private var aOffset:Number = 0;
		private var radx:Number = 0;
		private var rady:Number = 0;
		private var ctrX:Number = 0;
		private var ctrY:Number = 0;
		private var range:int = 0;
		
        /**
         * Creates or reuses an instance of CircularPath.
         *  
         * @param       alist
         * @param x1    Control x1.
         * @param y1    Control y1
         * @param x2    Control x2.
         * @param y2    Control y2.
         * @param x3    The x destination.
         * @param y3    The y destination.
         * @param wait  The delay before starting (in milliseconds).
         * @param dur   The animation duration (in milliseconds).
         * 
         * @return  A CircularPath object. 
         */
        public static function make(alist:AnimList, angle:Number, radius:Number, clockwise:Boolean, range:int, wait:int, dur:int):CircularPath 
        {
			// recycle or create an instance
			if (bpool.length > 0)
			{
				var anim:CircularPath = bpool.pop();
			}
			else
			{
				anim = new CircularPath();
				anim.usePool = false;
			}
			// initialize the variables
			anim.initNorm(wait, dur);
			anim.initPath(0, 0);
			
			anim.range = range;
			anim.radx = radius;
			anim.rady = radius;
			anim.ccw = !clockwise;
			anim.ctrX = alist.dob.x+NumberUtils.calcX(anim.radx, angle);
			anim.ctrY = alist.dob.y+NumberUtils.calcY(anim.rady, angle);
			anim.aOffset = (angle+180)%360;
			
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
			startListener = null;
			if (bpool.indexOf(this) == -1) 
			{
				bpool.push(this);
			}
		}
		
		/**
		 * Updates the display object location on the path.
		 */
		override protected function updateLocation():void 
		{
			var n:Number = (aOffset+(control*range))%360;
			var a:Number = (this.ccw ? 360-n : n)/180*Math.PI;
			alist.dob.x = Math.round(this.ctrX+this.radx*Math.cos(a));
			alist.dob.y = Math.round(this.ctrY+this.rady*Math.sin(a));
		}		
						
		/**
		 * Called at the start of the first call to animate().
		 */
		override protected function firstTime():void 
		{
			super.firstTime();
			
			var a:Number = ((ccw ? 360-this.aOffset : this.aOffset)+180)%360;
			this.ctrX = alist.dob.x+NumberUtils.calcX(this.radx,a);
			this.ctrY = alist.dob.y+NumberUtils.calcY(this.rady,a);
			
			if (startListener != null) {
				startListener(this);
				startListener = null;
			}
		}		
    
        /** Swaps the starting and ending values. */
		override protected function swapEnds():void 
		{
            if (easing != EASE_NONE && easing != EASE_BOTH) 
			{
            	easing = easing == EASE_IN ? EASE_OUT : EASE_IN;
            }
			ccw = !ccw;
			if (ccw)
			{
				aOffset = aOffset-range;
			}
			else
			{
				aOffset = aOffset+range;
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
			var cpath:CircularPath = CircularPath.make(helper.alist,
				tokenizer.getNumber("angle", 0),
				tokenizer.getNumber("radius", 100),
				tokenizer.getBoolean("clockwise", true),
				tokenizer.getInt("range", 360),
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1000)
			);
			helper.parseEasingAttribute(cpath, tokenizer);
			helper.parseAnimAttributes(cpath, tokenizer);
			tokenizer.destroy();
		}
		
	}
}