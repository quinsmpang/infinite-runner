/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.common.util.FindChild;
    import com.playdom.gas.AnimList;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Sprite;

	/**
	 * Changes the image of a Bitmap object over time.
	 * 
	 * @author Rob Harris
	 */
	public class Animate extends Normalizer	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/**  Called each time the loop is completed. */
        public var loopListener:Function;
		
		/** Starting index value. */
		private var start:int;
				
		/** Ending index value. */
		private var end:int;
		
		private var offset:int;
		
		private var dx:Array;
		private var dy:Array;
		private var invert:Boolean;
		private var paused:Boolean;
		private var remoteMovie:MovieClip = null;
		private var bitmap:Bitmap;
		private var img_seq:Array;
		private var curr_frm:int;
		private var x_mult:int;
		public var bitmapIndex:int;
		private var movieName:String;
		
        /**
         * Creates or reuses an instance of Flipbook.
         * 
         * @return  A Flipbook object. 
         */
        public static function make(alist:AnimList, wait:int, dur:int, seq:Array, movie:String=null, dx:Array=null, dy:Array=null):Animate 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Animate = pool.pop();
			}
			else
			{
				anim = new Animate();
			}
			// initialize the variables
			anim.initNorm(wait, dur);
			anim.dx = dx;
			anim.dy = dy;
			anim.curr_frm = -1;
			anim.x_mult = 1;
			anim.invert = false;
			anim.paused = false;
			anim.loop = true;
			anim.movieName = movie;
			anim.bitmapIndex = 0;
			
			// add it to the parent list
			alist.add(anim);
			anim.start = anim.end = 0;
			anim.setSeq(seq, dur);
			return anim;
        }     
		
		/**
		 * Sets a frame and pauses the animation.
		 *
		 * @param seq The new sequence or null to pause.
		 */
		public function setFrame( frm:int ):void 
		{
			if (curr_frm != frm) 
			{
				curr_frm = frm;
				if (invert)
				{
					frm = img_seq.length-1-frm;
				}
				if (remoteMovie) 
				{
					remoteMovie.gotoAndStop(frm);
				} 
				else if ( bitmap != null && img_seq != null) 
				{
					bitmap.bitmapData = img_seq[frm];
				}
				paused = true;
			}			
		}
		
		/**
		 * Sets a new sequence.
		 *
		 * @param seq The new sequence or null to pause.
		 */
		public function setSeq(seq:Array, dur:int):void 
		{
			if ( seq ) 
			{
				if ( seq[0] is BitmapData )
				{
					img_seq = seq;
					setRange(0, seq.length-1);
				}
				else if ( seq[0] is String )
				{
					img_seq = new Array();
					for (var i:int = 0; i < seq.length; i++) 
					{
						img_seq[i] = alist.control.bitmapAssets.getBitmapData(seq[i]);
					}
					setRange(0, seq.length-1);
				}
				else
				{
					setRange( seq[ 0 ], seq[ 1 ] );
				}
				this.dur = dur;
				paused = false;
			}
			else
			{
				paused = true;
			}
		}
		
		/**
		 * Sets or releases the pause control.
		 *  
		 * @param on  True to pause the animation.
		 */
		public function pause(on:Boolean=true):void
		{
			paused = on;
		}
		
		/**
		 * Sets the starting and ending values.
		 *
		 * @param start The starting value.
		 * @param target The ending value.
		 */
		public function setRange(start:Number, target:Number):void 
		{
			this.end = target;
			this.start = start;
		}
		
		/**
		 * Sets the beginning frame.
		 *
		 * @param frame The offset to the first frame.
		 */
		public function setOffset(frame:Number):void 
		{
			var range:int = end-start+1;
			this.offset = frame*dur/range;
		}
								
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			super.destroy();
            loopListener = null;
            dx = null;
            dy = null;
            remoteMovie = null;
			bitmap = null;
			img_seq = null;
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
			var done:Boolean = super.animate();
			if (!paused && alist.control.time >= stime+wait) 
			{
				var frm:int = Math.floor(start+((end-start+1)*control));
				if (frm >= end)
				{
					frm = end;
				}
				if (curr_frm != frm) 
				{
					curr_frm = frm;
					if (invert)
					{
						frm = img_seq.length-1-frm;
					}
					if (remoteMovie) 
					{
						remoteMovie.gotoAndStop(frm);
					} 
					else if ( bitmap != null && img_seq != null) 
					{
						bitmap.bitmapData = img_seq[frm];
					}
					if (dx) {
						alist.dob.x += dx[frm]*x_mult;
					}
					if (dy) {
						alist.dob.y += dy[frm];
					}
				}				
                done = stime+wait+dur < alist.control.time;
			}
			if (done && loopListener != null)
			{
				loopListener(this);
			}
			return done;
		}	
		
                            
        /**
         * Called at the start of the first call to animate().
         */
        override protected function firstTime():void 
		{
            stime = alist.control.time - offset;
			if ( movieName && alist.dob is Sprite )
			{
				remoteMovie = FindChild.byName( movieName, alist.dob as Sprite ) as MovieClip;
				if ( remoteMovie )
				{
					setRange(1, remoteMovie.currentScene.numFrames);
					paused = false;
				}
			}
			else if (alist.dob is MovieClip) 
			{
				remoteMovie = alist.dob as MovieClip;
				if ( start == end )
				{
					setRange(1, remoteMovie.currentScene.numFrames);
				}
				paused = false;
			}
			else if (alist.dob is Sprite) 
			{
				bitmap = Bitmap((alist.dob as Sprite).getChildAt(bitmapIndex));
			}
			else 
			{
				bitmap = Bitmap(alist.dob);
			}
        }       		
    
		/**
		 * Flips the image horizontally. 
		 */
        public function hflip():void 
		{
            x_mult = -x_mult;
            alist.dob.scaleX = -alist.dob.scaleX;        	
        }
		
		/** Swaps the starting and ending values. */
		override protected function swapEnds():void
		{
			super.swapEnds();
			invert = !invert;
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
			var seq:Array = helper.makeSeq(tokenizer.getString("base", "strip"), 
				tokenizer.getNumber("start", 1), 
				tokenizer.getNumber("end", 0),
				tokenizer.getString("seq", ""));
			var flipbook:Animate = make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1000),
				seq
			);
			flipbook.setOffset(tokenizer.getInt("offset",0));
			helper.parseEasingAttribute(flipbook, tokenizer);
			helper.parseAnimAttributes(flipbook, tokenizer);
			tokenizer.destroy();
		}

	}
}