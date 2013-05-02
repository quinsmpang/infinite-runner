/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.common.util.FindChild;
    import com.playdom.gas.AnimList;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.text.TextField;

	/**
	 * Changes a display object property.
	 * 
	 * @author Rob Harris
	 */
	public class Set extends AnimBase
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Property key. */
		private var key:String;
		
		/** Property value. */
		public var value:String;
		
		/** Target display object (or null for self). */
		public var target:String;
		
        /**
         * Creates or reuses an instance of Setter.
         *  
		 * @param alist      The parent anim list.
         * @param wait       The initial delay.
         * @param key        The property key ("visible", "image", "text").
         * @param value      The property value.
		 * 
         * @return  A Setter object. 
		 */
        public static function make(alist:AnimList, wait:int, key:String, value:String, target:String=null):Set 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Set = pool.pop();
			}
			else
			{
				anim = new Set();
			}
			// initialize the variables
			anim.wait = wait;
			anim.key = key;
			anim.value = value;
			anim.target = target;
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
			key = null;
			value = null;
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
			if (stime == 0) 
			{
				stime = alist.control.time;
			}
			if (alist.control.time >= stime+wait) 
			{
				if (key == "seq")
				{
					doSeq();
					return true;
				}
				if ( target == null )
				{
					var dob:DisplayObject = alist.dob;
				}
				else if ( target.indexOf( "~" ) == 0 && alist.dob is Sprite )
				{
					dob = FindChild.byName( target.substr( 1 ), alist.dob as Sprite );
				}
				else
				{
					dob = FindChild.byName( target, alist.dob.stage );
				}
				if (dob != null)
				{
					switch (key) 
					{
						case "visible": 
						{
							dob.visible = value == "true";
							break;
						}
						case "x": 
						{
							dob.x = parseInt(value);
							break;
						}
						case "y": 
						{
							dob.y = parseInt(value);
							break;
						}
						case "alpha": 
						{
							dob.alpha = parseFloat(value);
							break;
						}
						case "image": 
						{
							dob = checkForAnchor( dob );
							if (dob is Bitmap) 
							{
								var bmd:BitmapData = alist.control.bitmapAssets.getBitmapData(value);
								if (bmd) 
								{
									(dob as Bitmap).bitmapData = bmd;
								}
							}
							break;
						}
						case "text": 
						{
							dob = checkForAnchor( dob );
							if (dob is TextField) 
							{
								(dob as TextField).text = value;
							}
							break;
						}
						case "color": 
						{
							dob = checkForAnchor( dob );
							if (dob is TextField) 
							{
								(dob as TextField).textColor = parseInt(value, 16);
							}
							break;
						}
						case "anchor": 
						{
							if (dob is Sprite) 
							{
								var remains:String = changeAnchor( value, checkForAnchor( dob ) );
								if ( remains )
								{
									var idx:int = remains.indexOf(",");
									if (idx != -1)
									{
										dob.x = parseInt(remains.substring(0, idx));
										dob.y = parseInt(remains.substr(idx+1));
									}
								}
							}
							break;
						}
						case "pause": 
						{
							if (target == null) 
							{
								alist.pause(value == "true");
							}
							else
							{
								var alist2:AnimList = alist.control.findAnimList(dob);
								if (alist2)
								{
									alist2.pause(value == "true");
								}
							}
							break;
						}
						default: 
						{
							// do nothing
						}
					}
				}
				return true;
			}
			return false;
		}
		
		private function changeAnchor( anchor:String, dob:DisplayObject ):String
		{
			if (anchor)
			{
				if (anchor != "center")
				{
					var idx:int = anchor.indexOf(",");
					if (idx != -1)
					{
						dob.x = parseInt(anchor.substring(0, idx));
						dob.y = parseInt(anchor.substr(idx+1));
					}
					idx = anchor.indexOf(",", idx + 1);
					if (idx != -1)
					{
						return anchor.substr( idx + 1 );
					}
				}
				else
				{
					dob.x = -dob.width/2;
					dob.y = -dob.height/2;
				}
			}
			return "";
		}
		
		private function checkForAnchor( dob:DisplayObject ):DisplayObject
		{
			if ( dob is Sprite )
			{
				return Sprite( dob ).getChildAt( 0 );
			}
			return dob;
		}
		
		private function doSeq():void
		{
			var anim:Animate = alist.findAnimByType(Animate) as Animate;
			if (anim)
			{
				if (value == "destroy")
				{
					anim.destroy();
				}
				else if (value == "pause")
				{
					anim.pause(true);
				}
				else if (value == "continue")
				{
					anim.pause(false);
				}
				else if (value)
				{
					var idx1:int = value.indexOf(",");
					if ( idx1 == -1 )
					{
						anim.setFrame( parseInt( value ) );
					}
					else
					{
						var idx2:int = value.indexOf(",", idx1+1);
						var idx3:int = value.indexOf(",", idx2+1);
						var base:String = value.substr(0, idx1);
						try
						{
							var start:int = parseInt(value.substring(idx1+1, idx2));
							var end:int = parseInt(value.substring(idx2+1, idx3));
							var dur:int = parseInt(value.substr(idx3+1));
							var arr:Array = [];
							for (var i:int = start; i <= end; i++)
							{
								arr.push(base+i);
							}
							anim.setSeq(arr, dur);
						}
						catch (err:Error)
						{
							// report error
						}
					}
				}
				else
				{
					anim.pause(true);
				}
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
			var setter:Set = Set.make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getString("key", ""),
				tokenizer.getString("value", ""),
				tokenizer.getString("target", null)
			);
			helper.parseAnimAttributes(setter, tokenizer);
			tokenizer.destroy();
		}
		
	}
}