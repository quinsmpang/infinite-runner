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
	public class Disassemble extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Particle group. */
		public var group:String;
		
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
		
		/** Temporary variables used by the XML parser. */
		private var tempVars:Hashtable;
		
        /**
         * Creates or reuses an instance of Disassembler.
         *  
         * @param wait  The initial delay.
         * @param key   The property key ("visible", "event").
         * @param value The property value.
         * 
         * @return  A Disassembler object. 
         */
        public static function make(alist:AnimList, wait:int, proto:String, group:String, modulo:int, tempVars:Hashtable):Disassemble 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Disassemble = pool.pop();
			}
			else
			{
				anim = new Disassemble();
			}
			
			// initialize the variables
			anim.tempVars = tempVars;
			anim.wait = wait;
			anim.group = group;
			anim.pixelHandler = proto;
			anim.modulo = modulo;
			anim.killDob = true;
			anim.pixelIdx = 0;
			anim.imageX = 0;
			anim.imageY = 0;
			anim.dx = 0;
			anim.dy = 0;
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
				var dobGroup:Array = group ? [] : null;
				// make the image invisible
				alist.dob.visible = false;
				
				// limit the number of pixels created per frame
				var max:int = pixelIdx+4000;	
				
				// set up the scanning variables
				var displayX:int = alist.dob.x+dx;
				var displayY:int = alist.dob.y+dy;
				if ( bmd )
				{
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
									// set up the variables to pass to the prototype creator
	//								tempVars.pixelIndex = pixelIdx++;
									tempVars.setInt("pixelIndex", pixelIdx++);
	//								tempVars.pixelARGB = color;
									tempVars.setString("pixelARGB", color.toString());
	//								tempVars.pixelColor = color.toString(16);
									tempVars.setString("pixelColor", color.toString(16));
									// create an instance of the prototype
									var pixel:AnimList = alist.control.createAnimList(pixelHandler);
									if (pixel)
									{
										// place the instance at its location in the bitmap
	//									pixel.dob.x = displayX+imageX;
	//									pixel.dob.y = displayY+imageY;
										tempVars.setString("pixelX", (pixel.dob.x = displayX+imageX).toString());
										tempVars.setString("pixelY", (pixel.dob.y = displayY+imageY).toString());
										
										if (dobGroup)
										{
											dobGroup.push(pixel);
										}
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
				if (dobGroup)
				{
					alist.control.setDobGroup(group, dobGroup);
				}

				// return true so that this anim is destroyed
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
			var anim:AnimBase = Disassemble.make(helper.alist,
				tokenizer.getInt("wait", 0),
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