/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimList;
    
    import flash.text.TextField;

	/**
	 * Changes a game state, config property, or fires an event.
	 * 
	 * @author Rob Harris
	 */
	public class Counter extends AnimBase
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** System context. */
		private var context:Object;
				
		/** Property value. */
		private var trigger:String;
		
		/** Property value. */
		private var key:String;
		
		/** Property value. */
		private var value:String;
		
		private var count:int;
		
		private var inc:int;
		
		private var max:int;
		
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
        public static function make(alist:AnimList, wait:int, trigger:String, key:String, value:String, inc:int, max:int, context:Object):Counter 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Counter = pool.pop();
			}
			else
			{
				anim = new Counter();
			}
			
			// initialize the variables
			anim.wait = wait;
			anim.key = key;
			anim.value = value;
			anim.trigger = trigger;
			anim.inc = inc;
			anim.max = max;
			anim.context = context;
			anim.stime = 0;
			anim.count = 0;
			anim.active = false;
			
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
			if (context && context.dispatcher != null)
			{
				context.dispatcher.removeKeyListener(trigger, handleTrigger);
			}
			trigger = null;
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
				if (!active)
				{
					active = true;
					if (context.dispatcher != null)
					{
						context.dispatcher.addKeyListener(trigger, handleTrigger);
					}
				}
			}
			return count >= max;
		}
		
		private var active:Boolean;
		
		private function handleTrigger(key0:String, value:String):void
		{
			count += inc;
			if (alist && alist.dob is TextField)
			{
				(alist.dob as TextField).text = count.toString();
			}
			if (count >= max && key)
			{
				context.dispatcher.dispatchKeyEvent(key, value);
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
			var anim:Counter = make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getString("trigger", ""),
				tokenizer.getString("key", ""),
				tokenizer.getString("value", ""),
				tokenizer.getInt("inc", 1),
				tokenizer.getInt("max", 10),
				context
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}