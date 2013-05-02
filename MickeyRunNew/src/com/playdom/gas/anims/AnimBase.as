/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
	/**
	 * Superclass for most animators.
	 * 
	 * @author Rob Harris
	 */
	public class AnimBase extends Anim
	{
        /** Indicates that animation should restart when done. */
        public var loop:Boolean;
        
        /** The number of times that the animation should be repeated. */
        public var repeat:int = -1;
           
		/** True if the rest of the animation list should be blocked. */
		public var block:Boolean = false;
		
		/** True if the display object should be killed when anim is done. */
		public var killDob:Boolean = false;
		
		/** A listener function to be called when the animation has completed. */
		public var listener:Function;

        /** Starting time. */
        protected var stime:uint;
                
        /** Delay before starting animation. */
        protected var wait:uint;
                        
        /** Duration of animation. */
        protected var dur:uint;
		
		/** Indicates that animation should reverse direction/order when done. */
		private var _osc:Boolean;
				
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			listener = null;
			block = false;
            killDob = false;
            repeat = -1;
            stime = 0;
            wait = 0;
            dur = 0;
            _osc = loop = false;
			super.destroy();
		}	
							
        /**
         * Restarts or reverses the animation cycle.
         */
        public function doLoop():void 
		{
            stime += dur;
            if (_osc)
			{
                swapEnds();
            }
        }
        
        /**
         * Swaps the beginning and end of the animation cycle.
         */
        protected function swapEnds():void 
		{
		}		
		
		/**
		 * True if anim should oscillate when done.
		 */
		public function set osc(v:Boolean):void 
		{
			_osc = loop = v;
		}		
		
		public function get osc():Boolean 
		{
			return _osc;
		}		
	}
}