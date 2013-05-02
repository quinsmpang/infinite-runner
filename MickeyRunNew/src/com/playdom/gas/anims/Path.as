/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;
    
    import flash.display.Sprite;
    import flash.geom.Rectangle;

	/**
	 * Moves the display object along a straight line from its current location to a new location.
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
	public class Path extends Normalizer	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Starting x. */
		protected var startx:Number;
				
		/** Starting y. */
		protected var starty:Number;
				
		/** Ending x. */
		protected var endx:Number;
				
		/** Ending y. */
		protected var endy:Number;
				
		/** X distance. */
		protected var xdist:Number;
				
		/** Y distance. */
		protected var ydist:Number;
		
		/** True if anchor point should be moved instead of display object */
		protected var pan:Boolean;
//		protected var panChild:DisplayObject;

		/** A listener function to be called each time the display object is moved. */
		public var moveListener:Function;
		
		/** True if recycling pool should be used. */
		protected var usePool:Boolean = true;
		
        /**
         * Creates or reuses an instance of this class.
         *  
         * @param x    The x destination.
         * @param y    The y destination.
		 * @param wait   The number of milliseconds to wait before starting.
		 * @param dur    The number of milliseconds for the duration of the activity.
         * 
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, x:Number, y:Number, wait:int, dur:int, pan:Boolean=false):Path 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Path = pool.pop();
			}
			else
			{
				anim = new Path();
			}
			anim.pan = pan;
			
			// initialize the variables
			anim.initNorm(wait, dur);
			anim.initPath(x, y);
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
		
		/**
		 * Initializes the path settings.
		 *  
		 * @param x The ending X location.
		 * @param y The ending Y location.
		 */
		protected function initPath(x:int, y:int):void
		{
			this.endx = x;
			this.endy = y;
		}
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			super.destroy();
			moveListener = null;
			if (usePool && pool.indexOf(this) == -1) 
			{
				pool.push(this);
			}
		}	

		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the destination has been reached. 
		 */
		override public function animate():Boolean 
		{
			var done:Boolean = super.animate();
			if (alist.control.time >= stime+wait) 
			{
				updateLocation();
			}
			return done;
		}	
									
		/**
		 * Updates the display object location on the path.
		 */
		protected function updateLocation():void 
		{
			if (pan)
			{
//				panChild.x = int((xdist*control)+startx);
//				panChild.y = int((ydist*control)+starty);
				var rect:Rectangle = alist.dob.scrollRect;
				rect.x = int((xdist*control)+startx);
				rect.y = int((ydist*control)+starty);
				alist.dob.scrollRect = rect;
			}
			else
			{
				alist.dob.x = int((xdist*control)+startx);
				alist.dob.y = int((ydist*control)+starty);
			}
			if (moveListener != null)
			{
				moveListener(this);
			}
		}		
				
		/**
		 * Called at the start of the first call to animate().
		 */
		override protected function firstTime():void 
		{
			super.firstTime();
			if (pan && (alist.dob as Sprite).numChildren > 0)
			{
				if ( alist.dob.scrollRect != null )
				{
					startx = alist.dob.scrollRect.x;
					starty = alist.dob.scrollRect.y;
				}
				else
				{
					pan = false;
				}
			}
			else
			{
				startx = alist.dob.x;
				starty = alist.dob.y;
			}
			xdist = endx - startx;
			ydist = endy - starty;			
		}		
    
        /** Swaps the starting and ending values. */
        override protected function swapEnds():void 
		{
            super.swapEnds();
            var tmp:Number = startx;
            startx = endx;
            endx = tmp;
            tmp = starty;
            starty = endy;
            endy = tmp;
            xdist = -xdist;
            ydist = -ydist;
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
			var path:Path = make(helper.alist,
				tokenizer.getInt("x", 0),
				tokenizer.getInt("y", 0),
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1000),
				tokenizer.getBoolean("pan", false)
			);
			helper.parseEasingAttribute(path, tokenizer);
			helper.parseAnimAttributes(path, tokenizer);
			tokenizer.destroy();
		}
		
	}
}