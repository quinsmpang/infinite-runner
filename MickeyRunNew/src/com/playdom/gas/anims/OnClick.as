/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.common.util.FindChild;
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

	/**
	 * Waits for a mouse click.
	 * 
	 * @author Rob Harris
	 */
	public class OnClick extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var context:Object;
		
		private var protoName:String;
		
		private var target:String;
		
		private var active:Boolean;
		
		private var clicked:Boolean;
		
		private var end_time:uint;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, dur:uint, proto:String, target:String, context:Object):OnClick 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:OnClick = pool.pop();
			}
			else
			{
				anim = new OnClick();
			}
			// initialize the variables
			anim.context = context;
			anim.target = target;
			anim.wait = wait;
			anim.dur = dur;
			anim.stime = 0;
			anim.protoName = proto;
			anim.active = false;
			anim.clicked = false;
			
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			if (alist && alist.dob)
			{
				alist.dob.removeEventListener(MouseEvent.CLICK, handleClick);
			}
			super.destroy();
			protoName = null;
			
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
			var control:AnimControl = alist.control;
			if (stime == 0)
			{	// first time this method is called
                stime = control.time;
	            end_time = dur == 0 ? int.MAX_VALUE : dur+control.time+wait;
			}
			if (control.time >= stime+wait)
			{	// past the wait period
				if (!active)
				{	// first time past wait period
					active = true;
					alist.dob.addEventListener(MouseEvent.CLICK, handleClick);
					if (alist.dob is Sprite)
					{	// show rollover mouse cursor
						var spr:Sprite = alist.dob as Sprite;
						spr.buttonMode = true;
						spr.mouseChildren = false;
						spr.useHandCursor = true;
					}
				}
				if (clicked)
				{	// display object has been clicked
					if (protoName)
					{	// create a prototype
						if (target)
						{	// target specified
							var dob:DisplayObject = FindChild.byName(target, context.playfieldLayer);
							if (dob)
							{	// target found
								var alist2:AnimList = alist.control.findAnimList(dob);
								if (!alist2)
								{
									alist2 = alist.control.attachAnimList(dob);
								}
								// add prototype to the specified target
								alist.control.makeProto(context, alist2, protoName);
							}
						}
						else
						{	// no target specified; create an independant prototype
							alist.control.createAnimList(protoName);
						}
					}
					clicked = false;
					return true;
				}
				return end_time < control.time;	// true indicates the anim is done
			}
			return false;
		}	
		
		/**
		 * Called when the display object is clicked.
		 *  
		 * @param evt  The associated event.
		 */
		private function handleClick(evt:Event):void
		{
			clicked = true;	// set flag to be used in the next animation call
			if (!loop)
			{	// single click specified; stop listeneing for clicks
				if (alist && alist.dob)
				{
					alist.dob.removeEventListener(MouseEvent.CLICK, handleClick);
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
			var anim:AnimBase = make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 0),
				tokenizer.getString("proto", ""),
				tokenizer.getString("target", ""),
				context
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}