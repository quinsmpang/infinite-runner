/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;
    import com.playdom.common.util.KeyDispatcher;
    
    import flash.events.Event;

	/**
	 * Listenes for a game state change, key event, or native event.
	 * 
	 * @author Rob Harris
	 */
	public class Listen extends AnimBase
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Dispatch type: native event. */
		public static const TYPE_NATIVE_EVENT:String = "dispatch";
		
		/** Dispatch type: key event. */
		public static const TYPE_EVENT:String = "event";
		
		/** Dispatch type: state change. */
		public static const TYPE_STATE:String = "state";

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
		
		private var dispatcher:KeyDispatcher;
		
        /**
         * Creates or reuses an instance of this class.
         *  
		 * @param alist      The parent anim list.
         * @param wait       The initial delay.
		 * @param type       The type of dispatch (TYPE_EVENT, TYPE_STATE, TYPE_NATIVE_EVENT).
         * @param key        The property key ("visible", "event").
         * @param value      The property value.
		 * @param context    The system context (gameState, config, dispatcher)
		 * 
		 * @return An instance of this class. 
		 */
        public static function make(alist:AnimList, wait:int, type:String, key:String, value:Object, context:Object):Listen 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Listen = pool.pop();
			}
			else
			{
				anim = new Listen();
			}
			
			// initialize the variables
			anim.wait = wait;
			anim.type = type;
			anim.key = key;
			anim.value = value;
			anim.context = context;
			anim.stime = 0;
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
			if ( key && dispatcher )
			{
				dispatcher.removeKeyListener( key, handleKeyEvent );
			}
			if ( type == TYPE_NATIVE_EVENT && key && context && context.eventDispatcher )
			{
				context.eventDispatcher.removeEventListener( key, handleNativeEvent );
			}
			super.destroy();
			key = null;
			value = null;
			type = null;
			context = null;
			dispatcher = null;
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
				if ( active )
				{
					return clicked;
				}
				switch (type) 
				{
					case TYPE_STATE: 
					{	// change game state
						if (context.gameState != null && key)
						{
							dispatcher = context.gameState.dispatcher;
							dispatcher.addKeyListener( key, handleKeyEvent );
						}
						break;
					}
					case TYPE_NATIVE_EVENT: 
					{	// dispatch event
						if (context.eventDispatcher != null && key)
						{
							context.eventDispatcher.addEventListener( key, handleNativeEvent );
						}
						break;
					}
					case TYPE_EVENT: 
					{	// dispatch key event
						if (context.dispatcher != null && key)
						{
							dispatcher = context.dispatcher;
							dispatcher.addKeyListener( key, handleKeyEvent );
							active = true;
						}
						break;
					}
				}
			}
			return false;
		}
		
		/**
		 * Called when the key event is dispatched.
		 *  
		 * @param evt  The associated event.
		 */
		private function handleKeyEvent( arg1:String, arg2:Object ):void
		{
			if ( !value || value == arg2 )
			{
				clicked = true;	// set flag to be used in the next animation call
				dispatcher.removeKeyListener( arg1, handleKeyEvent );
			}
		}
		
		/**
		 * Called when the native event is dispatched.
		 *  
		 * @param evt  The associated event.
		 */
		private function handleNativeEvent( evt:Event ):void
		{
			clicked = true;	// set flag to be used in the next animation call
			context.eventDispatcher.removeEventListener( key, handleNativeEvent );
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
			var evt:Listen = make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getString("type", Dispatch.TYPE_EVENT),
				tokenizer.getString("key", ""),
				tokenizer.getString("value", ""),
				context
			);
			helper.parseAnimAttributes(evt, tokenizer);
			tokenizer.destroy();
		}
		
	}
}