/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;

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
	public class BezierPath extends Path	
	{
		/** Called when the path is started. */
		public var startListener:Function;
		
		/** The recycling pool */
		private static var bpool:Array = [];
		
		/** control points */
		private var p1x:Number;
		private var p1y:Number;
		private var p2x:Number;
		private var p2y:Number;
		
        /**
         * Creates or reuses an instance of BezierPath.
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
         * @return  A BezierPath object. 
         */
        public static function make(alist:AnimList, x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, wait:int, dur:int):BezierPath 
        {
			// recycle or create an instance
			if (bpool.length > 0)
			{
				var anim:BezierPath = bpool.pop();
			}
			else
			{
				anim = new BezierPath();
				anim.usePool = false;
			}
			// initialize the variables
			anim.initNorm(wait, dur);
			anim.initPath(x3, y3);
			anim.p1x = x1;
			anim.p1y = y1;
			anim.p2x = x2;
			anim.p2y = y2;
			// add it to the parent list
			alist.add(anim);
			return anim;
        }       
		
		/**
		 * Sets the starting location.
		 *  
		 * @param x The X coordinate.
		 * @param y The Y coordinate.
		 */
		public function setStart(x:Number, y:Number):void 
		{
			startx = x;
			starty = y;
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
			alist.dob.x = Math.round((startx+control*(-startx*3+control*(3*startx-startx*control)))+control*(3*p1x+control*(-6*p1x+ 
					                 p1x*3*control))+control*control*(p2x*3-p2x*3*control)+endx*control*control*control); 
			alist.dob.y = Math.round((starty+control*(-starty*3+control*(3*starty-starty*control)))+control*(3*p1y+control*(-6*p1y+ 
					                 p1y*3*control))+control*control*(p2y*3-p2y*3*control)+endy*control*control*control);
		}		
						
		/**
		 * Called at the start of the first call to animate().
		 */
		override protected function firstTime():void 
		{
			super.firstTime();
			setStart(alist.dob.x, alist.dob.y);
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
            //			super.swapEnds();
			var tmp:Number = startx;
			startx = endx;
			endx = tmp;
			tmp = p1x;
			p1x = p2x;
			p2x = tmp;
			tmp = starty;
			starty = endy;
			endy = tmp;
			tmp = p1y;
			p1y = p2y;
			p2y = tmp;
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
			var bpath:BezierPath = make( helper.alist,
				tokenizer.getInt( "x1", 0 ),
				tokenizer.getInt( "y1", 0 ),
				tokenizer.getInt( "x2", 100 ),
				tokenizer.getInt( "y2", 100 ),
				tokenizer.getInt( "x3", 200 ),
				tokenizer.getInt( "y3", 200 ),
				tokenizer.getInt( "wait", 0 ),
				tokenizer.getInt( "dur", 1000 )
			);
			helper.parseEasingAttribute( bpath, tokenizer );
			helper.parseAnimAttributes( bpath, tokenizer );
			tokenizer.destroy();
		}
		
	}
}