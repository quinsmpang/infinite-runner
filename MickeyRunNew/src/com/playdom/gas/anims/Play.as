/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    
    import flash.media.Sound;
    import flash.media.SoundChannel;

	/**
	 * Plays a sound.
	 * 
	 * @author Rob Harris
	 */
	public class Play extends AnimBase	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var soundKey:String;
		
		private var chan:SoundChannel;
		
		private var playing:Boolean;
		
		private var end_time:uint;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, dur:uint, key:String):Play 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Play = pool.pop();
			}
			else
			{
				anim = new Play();
			}
			// initialize the variables
			anim.wait = wait;
			anim.dur = dur;
			anim.stime = 0;
			anim.soundKey = key;
			anim.playing = false;
			
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
			chan = null;
			soundKey = null;
			
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
	            end_time = dur == 0 ? int.MAX_VALUE : dur+control.time+wait;
			}
			if (control.time >= stime+wait)
			{
				if (!playing && soundKey)
				{
					playing = true;
					var sound:Sound = alist.control.soundAssets.getSound(soundKey); 
					if (sound)
					{
						chan = sound.play();
					}
				}
				else if (end_time < control.time)
				{
					if (chan)
					{
						chan.stop();
					}
				}
				return end_time < control.time;
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
			var anim:Play = Play.make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1000),
				tokenizer.getString("src", "")
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}