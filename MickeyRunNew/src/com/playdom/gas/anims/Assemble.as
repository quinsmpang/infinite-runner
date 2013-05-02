/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;
    import com.playdom.common.util.Hashtable;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;

	/**
	 * Breaks a bitmap into individual pixels that can fly off.
	 * 
	 * @author Rob Harris
	 */
	public class Assemble extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Particle group. */
		private var group:String;
		
		/** The bitmap data. */
		private var bmd:BitmapData;
		
		/** The pixel handler. */
		private var pixelHandler:String;
		
		private var pixelIdx:int;
		private var imageX:int;
		private var imageY:int;
		private var dx:int;
		private var dy:int;
		private var modulo:int;
		private var firstTime:Boolean;
		
		/** Temporary variables used by the XML parser. */
		private var tempVars:Hashtable;
		
        /**
         * Creates or reuses an instance of Assembler.
         *  
         * @param wait  The initial delay.
         * @param key   The property key ("visible", "event").
         * @param value The property value.
         * 
         * @return  An Assembler object. 
         */
        public static function make(alist:AnimList, wait:int, dur:int, proto:String, group:String, modulo:int, tempVars:Hashtable):Assemble 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Assemble = pool.pop();
			}
			else
			{
				anim = new Assemble();
			}
			
			// initialize the variables
			anim.tempVars = tempVars;
			anim.wait = wait;
			anim.group = group;
			anim.dur = dur;
			anim.pixelHandler = proto;
			anim.modulo = modulo;
			anim.pixelIdx = 0;
			anim.imageX = 0;
			anim.imageY = 0;
			anim.dx = 0;
			anim.dy = 0;
			anim.stime = 0;
			anim.firstTime = true;
			
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
			tempVars = null;
			pixelHandler = null;
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
			// is this the first time this was called?
			if (stime == 0) 
			{
				// set the starting time
				stime = alist.control.time;
				
				// find the bitmap object
				if (alist.dob is Bitmap)
				{
					// found the bitmap object
					var bmap:Bitmap = Bitmap(alist.dob);
					bmd = bmap.bitmapData;
				}
				else if (alist.dob is Sprite)
				{
					// found a pivot point wrapper
					var spr:Sprite = alist.dob as Sprite;
					if (spr.numChildren > 0)
					{
						// look for the bitmap object
						var child:DisplayObject = spr.getChildAt(0); 
						if (child is Bitmap)
						{
							// found the bitmap object
							bmap = child as Bitmap;
							bmd = bmap.bitmapData;
							dx = bmap.x;
							dy = bmap.y;
						}
					}
				}
				else
				{
					// not a valid display object... kill this animator
					return true;
				}
			}
			// wait for the starting time
			if (alist.control.time >= stime+wait) 
			{
				if (firstTime)
				{
					firstTime = false;

					var dobGroup:Array = group ? alist.control.getDobGroup(group) : null;
					
					// limit the number of pixels created per frame
					var max:int = pixelIdx+4000;	
					
					// set up the scanning variables
					var displayX:int = alist.dob.x+dx;
					var displayY:int = alist.dob.y+dy;
					var w:int = bmd.width;
					var h:int = bmd.height;
					// scan the bitmap left to right, top to bottom
					for (; imageY < h; imageY++)
					{
						for (; imageX < w; imageX++)
						{
							// skip pixels based on the modulo setting
							if (pixelIdx%modulo == 0)
							{
								// fetch the next pixel color
								var color:uint = bmd.getPixel32(imageX, imageY);
								// is the pixel is visible?
								if (color > 0xffffff)
								{
									var oldPixel:AnimList = dobGroup && dobGroup.length > 0 ? dobGroup.pop() : null;
										
									// set up the variables to pass to the prototype creator
									tempVars.setInt("pixelIndex", pixelIdx++);
									tempVars.setString("pixelARGB", color.toString());
									tempVars.setString("pixelAlpha", ((color >>> 24)/255).toString());
									tempVars.setString("pixelColor", color.toString(16));
									tempVars.setInt("pixelX", displayX+imageX);
									tempVars.setInt("pixelY", displayY+imageY);
									tempVars.setInt("pixelDur", dur);
									
									// create an instance of the prototype
									var pixel:AnimList = alist.control.createAnimList(pixelHandler);
									
									if (oldPixel)
									{
										pixel.dob.x = oldPixel.dob.x;
										pixel.dob.y = oldPixel.dob.y;
										oldPixel.destroy();
									}
								}
							}
							else
							{	// skipping a pixel
								pixelIdx++;
							}
							// stop if limit reached - pick it up next frame
							if (pixelIdx >= max)
							{
								return false;
							}
						}
						// next pixel row
						imageX = 0;
					}
				}
				else if (alist.control.time >= stime+wait+dur) 
				{
					dobGroup = group ? alist.control.getDobGroup(group) : null;
					if (dobGroup)
					{
						while (dobGroup.length > 0)
						{
							var part:AnimList = dobGroup.pop();
							part.destroy();
						}
						alist.control.setDobGroup(group, null);
					}
					// return true so that this anim is destroyed
					return true;
				}
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
			var anim:AnimBase = make(	helper.alist,
										tokenizer.getInt("wait", 0),
										tokenizer.getInt("dur", 1000),
										tokenizer.getString("proto", ""),
										tokenizer.getString("group", ""),
										tokenizer.getInt("mod", 1), 
										context.animVars
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}