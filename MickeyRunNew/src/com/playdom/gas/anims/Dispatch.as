/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

	/**
	 * Changes a game state, config property, or fires an event.
	 * 
	 * @author Rob Harris
	 */
	public class Dispatch extends AnimBase
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Dispatch type: native event. */
		public static const TYPE_NATIVE_EVENT:String = "dispatch";
		
		/** Dispatch type: key event. */
		public static const TYPE_EVENT:String = "event";
		
		/** Dispatch type: state change. */
		public static const TYPE_STATE:String = "state";
		
		/** Dispatch type: config setting. */
		public static const TYPE_SETTING:String = "setting";

		/** Property key. */
		private var key:String;

		/** Dispatch type. */
		private var type:String;
		
		/** System context. */
		private var context:Object;
				
		/** Property value. */
		private var value:Object;
		
		private var active:Boolean;
		
		private var clicked:Boolean;
		
		private var onclick:Boolean;
		
        /**
         * Creates or reuses an instance of this class.
         *  
		 * @param alist      The parent anim list.
         * @param wait       The initial delay.
		 * @param type       The type of dispatch (TYPE_EVENT, TYPE_STATE, TYPE_SETTING).
         * @param key        The property key ("visible", "event").
         * @param value      The property value.
		 * @param context    The system context (gameState, config, dispatcher)
		 * 
		 * @return An instance of this class. 
		 */
        public static function make(alist:AnimList, wait:int, type:String, key:String, value:Object, onclick:Boolean, context:Object):Dispatch 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Dispatch = pool.pop();
			}
			else
			{
				anim = new Dispatch();
			}
			
			// initialize the variables
			anim.wait = wait;
			anim.type = type;
			anim.key = key;
			anim.value = value;
			anim.context = context;
			anim.stime = 0;
			anim.onclick = onclick;
			anim.active = false;
			anim.clicked = false;
			
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
		
		public static function makeEvent( alist:AnimList, wait:int, key:String, value:Object, onclick:Boolean, context:Object):Dispatch
		{
			return make( alist, wait, TYPE_EVENT, key, value, onclick, context );
		}
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			if ( alist && alist.dob )
			{
				alist.dob.removeEventListener(MouseEvent.CLICK, handleClick);
			}
			super.destroy();
			key = null;
			value = null;
			type = null;
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
			if (stime == 0) 
			{	// first time this method is called
				stime = alist.control.time;
			}
			if (alist.control.time >= stime+wait) 
			{	// past wait period
				if (onclick && !clicked)
				{	// waiting for click
					if (!active)
					{	// first time past wait period
						active = true;
						// set up click listener
						alist.dob.addEventListener(MouseEvent.CLICK, handleClick);
						if (alist.dob is Sprite)
						{	// show rollover mouse cursor if possible
							var spr:Sprite = alist.dob as Sprite;
							spr.buttonMode = true;
							spr.mouseChildren = false;
						}
					}
				}
				else
				{	// ready to dispatch
					switch (type) 
					{
						case TYPE_STATE: 
						{	// change game state
							if (context.gameState != null && key)
							{
								context.gameState.setString(key, value);
							}
							break;
						}
						case TYPE_SETTING: 
						{	// change configuration setting
							if (context.config != null && key)
							{
								context.config.setString(key, value);
							}
							break;
						}
						case TYPE_NATIVE_EVENT: 
						{	// dispatch event
							if (context.eventDispatcher != null && key)
							{
								context.eventDispatcher.dispatchEvent(new Event(key));
							}
							break;
						}
						case TYPE_EVENT: 
						{	// dispatch key event
							if (context.dispatcher != null && key)
							{
								context.dispatcher.dispatchKeyEvent(key, value);
							}
							break;
						}
					}
					clicked = false;
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Called when the display object is clicked.
		 *  
		 * @param evt  The associated event.
		 */
		private function handleClick(evt:MouseEvent):void
		{
			clicked = true;	// set flag to be used in the next animation call
			if (!loop && alist && alist.dob )
			{	// single click specified; stop listeneing for clicks 
				alist.dob.removeEventListener(MouseEvent.CLICK, handleClick);
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
			var evt:Dispatch = Dispatch.make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getTag(),
				tokenizer.getString("key", ""),
				tokenizer.getString("value", ""),
				tokenizer.getBoolean("onclick", false),
				context
			);
			helper.parseAnimAttributes(evt, tokenizer);
			tokenizer.destroy();
		}
		
	}
}