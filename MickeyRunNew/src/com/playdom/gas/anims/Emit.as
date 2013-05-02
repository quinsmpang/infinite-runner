/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.common.util.FindChild;
    import com.playdom.common.util.Hashtable;
    import com.playdom.gas.AnimList;
    import com.playdom.gas.interfaces.IHflip;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.Rectangle;

	/**
	 * Creates one or more AnimList objects over time.
	 *
     * @see AnimList#makeAnimList() 
     * @see AnimFactory#makeEmitter() 
	 * 
	 * @author Rob Harris
	 */
	public class Emit extends AnimBase implements IHflip 
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
        private var createTime:int;
        private var vol:int;
		private var zone:Rectangle;
		private var dx:int;
        private var dy:int;
        private var gap:int;
		private var place:Boolean;
		private var placer:Function;
		private var placerParms:String;
		private var mouse:Boolean;
		private var proto:Array;
		private var target:String;
		private var layer:String;
		private var context:Object;
		
		/** Temporary variables used by the XML parser. */
		private var tempVars:Hashtable;
		
        /**
         * Creates or reuses an instance of this class.
         * 
		 * @param alist  The anim list.
		 * @param wait   The number of milliseconds to wait before starting.
		 * @param dur    The number of milliseconds for the duration of the activity.
		 * @param proto  The name of the prototype to emit.
		 * @param vol    The number of prototypes to emit at one time.
		 * @param gap    The number of milliseconds to wait before emitting more.
		 * @param placeStr The placement of the prototypes (center, x,y, or x,y,w,h)
		 * 
		 * @return  An instance of this class. 
		 */
        public static function make(alist:AnimList, wait:int, dur:int, proto:String, vol:int=1, gap:int=1000, placeStr:String="", context:Object=null, target:String="", layer:String=""):Emit 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Emit = pool.pop();
			}
			else
			{
				anim = new Emit();
			}
			// initialize the variables
			anim.target = target;
			anim.layer = layer;
			anim.context = context;
			anim.tempVars = context.animVars;
			anim.wait = wait;
			anim.dur = dur;
			if (dur == -1)
			{
				dur = int.MAX_VALUE;
			}
			if (proto.charAt(0) == "[")
			{
				anim.proto = proto.substring(1, proto.length-1).split(",");
			}
			else
			{
				anim.proto = [proto];
			}
			anim.vol = vol;
			anim.gap = gap;
			anim.dx = 0;
			anim.dy = 0;
			anim.place = false;
			anim.mouse = false;
			if (placeStr)
			{
				if (placeStr == "cursor")
				{
					anim.mouse = true;
					anim.place = true;
				}
				else
				{
					var idx0:int = placeStr.indexOf(",");
					var idx1:int = placeStr.indexOf(",", idx0+1);
					if (idx1 == -1)
					{	// not a rectangle
						if (idx0 != -1)
						{	// a point
							anim.dx = parseInt(placeStr.substring(0, idx0));
							anim.dy = parseInt(placeStr.substr(idx0+1));
							anim.place = true;
						}
						else
						{	// maybe a placer
							idx0 = placeStr.indexOf(":");
							if (idx0 != -1)
							{
								anim.placer = alist.control.getPlacer(placeStr.substring(0, idx0));
								if (anim.placer != null)
								{
									anim.placerParms =  placeStr.substr(idx0+1);
									anim.place = true;
								}
							}
						}
					}
					else
					{
						var idx2:int = placeStr.indexOf(",", idx1+1);
						if (idx2 != -1)
						{	// a rectangle
							anim.zone = new Rectangle(parseInt(placeStr.substring(0, idx0)),
								parseInt(placeStr.substring(idx0+1, idx1)),
								parseInt(placeStr.substring(idx1+1, idx2)),
								parseInt(placeStr.substr(idx2+1)));
							anim.place = true;
						}
					}
				}
			}
			anim.stime = 0;
			anim.createTime = 0;
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
			proto = null;
			if (placer != null)
			{
				placer(null, null);
				placer = null;
				placerParms = null;
			}
			zone = null;
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
                createTime = alist.control.time+wait;
			}
			if (alist.control.time >= stime+wait) 
			{
	            if (createTime <= alist.control.time) 
				{
	                createTime += gap;
					
					if ( layer )
					{
						context.tempLayer = FindChild.byName( layer, context.topLayer );
					}

	                for (var i:int=0; i < vol; i++)
	                {
						var protoName:String;
						if (proto.length > 1)
						{
							protoName = proto[Math.floor(Math.random()*proto.length)];
						}
						else
						{
							protoName = proto[0];
						}
						var placex:int = 0;
						var placey:int = 0;
	                	if (place) 
						{
							if (placer != null)
							{
//								if (placer(alist2, placerParms))
//								{
//									return true;
//								}
							}
							else if (mouse)
							{
								placex = alist.dob.parent.mouseX;
								placey = alist.dob.parent.mouseY;
							}
							else if (zone)
							{
								placex = alist.dob.x+zone.x+Math.floor(Math.random()*zone.width);
								placey = alist.dob.y+zone.y+Math.floor(Math.random()*zone.height);
							}
							else
							{
								placex = alist.dob.x+dx;
								placey = alist.dob.y+dy;
//								tempPoint.x = 0;
//								tempPoint.y = 0;
//								tempPoint = alist.dob.localToGlobal(tempPoint);
//								placex = tempPoint.x+dx;
//								placey = tempPoint.y+dy;
							}
							if (tempVars != null)
							{
								tempVars.setInt("emitX", placex);
								tempVars.setInt("emitY", placey);
							}
	                	}
						
						
//						var alist2:AnimList = alist.control.createAnimList(protoName);
						if (target)
						{	// target specified
							var dob:DisplayObject = FindChild.byName( target, context.playfieldLayer );
							if (dob)
							{	// target found
								var alist2:AnimList = alist.control.findAnimList(dob);
								if (!alist2)
								{
									alist2 = alist.control.attachAnimList(dob);
								}
								// add prototype to the specified target
								//								context.tempAlist = alist2;
								//								alist.control.createAnimList(protoName);
								//								context.tempAlist = null;
								alist.control.makeProto(context, alist2, protoName);
							}
						}
						else
						{	// no target specified; create an independant prototype
							alist2 = alist.control.createAnimList(protoName);
						}
						
						if (place && alist2 != null) 
						{
							alist2.dob.x = placex;
							alist2.dob.y = placey;
						}
	                }	
	            }
				context.tempLayer = null;
				return stime+wait+dur < alist.control.time;
			}
			return false;
		}
		
//		private var tempPoint:Point = new Point();
		
		public function hflip():void
		{
			if (place)
			{
				if (placer != null)
				{
					// do nothing
				}
				else if (mouse)
				{
					// do nothing
				}
				else
				{
					var parent:Sprite = alist.dob as Sprite;
					var child:DisplayObject = parent.getChildAt(0);
					var x1:int = child.x-dx;
					if (zone)
					{
						zone.x = -zone.x;
					}
					else
					{
						dx = -dx;
					}
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
			var name:String = tokenizer.getString("proto", "");
			if (name.charAt(0) == '%')
			{
				name = helper.getSetting(name.substr(1), "");
			}
			var emitter:Emit = make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1),
				name,
				tokenizer.getInt("vol", 1),
				tokenizer.getInt("gap", 100000),
				tokenizer.getString("place", ""),
				context, 
				tokenizer.getString("target", ""), 
				tokenizer.getString("layer", "") 
			);
			helper.parseAnimAttributes(emitter, tokenizer);
			tokenizer.destroy();
		}
		
	}
}