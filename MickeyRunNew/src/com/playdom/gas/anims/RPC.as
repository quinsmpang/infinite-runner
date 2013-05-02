/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;

	/**
	 * Plays a sound.
	 * 
	 * @author Rob Harris
	 */
	public class RPC extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var cmd:String;
		
		private var data:String;
		
		private var gameId:String;
		
		private var context:Object;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, cmd:String, data:String, gameId:String, context:Object):RPC 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:RPC = pool.pop();
			}
			else
			{
				anim = new RPC();
			}
			// initialize the variables
			anim.wait = wait;
			anim.stime = 0;
			anim.cmd = cmd;
			anim.data = data;
			anim.context = context;
			anim.gameId = gameId;
			
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
			{
                stime = control.time;
			}
			if (control.time >= stime+wait)
			{
				context.commands.sendRPC({cmd:cmd,data:data,game:gameId});
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
			var anim:AnimBase = make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getString("cmd", ""),
				tokenizer.getString("data", ""),
				tokenizer.getString("game", "0"),
				context
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}