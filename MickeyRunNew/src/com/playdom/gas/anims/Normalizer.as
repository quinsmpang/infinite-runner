/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
 	import com.playdom.gas.AnimControl;
 	
    /**
     * Changes a control value from 0 to 1 over a specified duration; the superclass for Path, Fader, etc.
     * 
     * @author Rob Harris
     */
    public class Normalizer extends AnimBase {
        /** Control value that goes from 0 to 1. */
        protected var control:Number;
                
        /**  Easing type: no easing */
        public static const EASE_NONE:int = 0;
                        
        /**  Easing type: ease-in */
        public static const EASE_IN:int = 1;
                        
        /**  Easing type: ease-out */
        public static const EASE_OUT:int = 2;
                        
        /**  Easing type: ease-in and ease-out */
        public static const EASE_BOTH:int = 3;
                        
        /**  Current easing type (EASE_NONE, EASE_IN, EASE_OUT, EASE_BOTH) */
        public var easing:int = EASE_NONE;
        
        /**
         * Creates an instance of this class.
         * 
         * @return This object so that calls can be chained.
         */
		protected function initNorm(wait:int, dur:int):void {
            this.wait = wait;
			if (dur <= 0)
			{
				dur = 1;
			}
            this.dur = dur;
            stime = 0;
            control = 0.0;
			easing = EASE_NONE;
        }
		
		protected var started:Boolean;
                
        /**
         * Updates the animation at a regular interval.
         */
        override public function animate():Boolean 
		{
            if (stime == 0) 
			{
				stime = alist.control.time;
				started = false;
            }
            if (alist.control.time < stime+wait) 
			{
                return false;
            }
			if (!started)
			{
				started = true;
				firstTime();
			}
            var t:Number = (alist.control.time-stime-wait);   // current time
//            Log.info(".animate: t = "+t, this);
            if (t < dur) 
			{
            	var c1:Number;   // new control value
            	switch (easing) {
                	case EASE_NONE:
					{
                        c1 = t/dur;
                    	break;
					}
                    case EASE_IN:
					{
                        t /= dur;
                        c1 = t*t;
                    	break;
					}
                    case EASE_OUT:
					{
                        t = dur-t;
                        t /= dur;
                        c1 = t*t;
                        c1 = 1-c1;
                    	break;
					}
                    case EASE_BOTH:
					{
                        t /= dur/2;
                        if (t < 1) {
                            c1 = t*t/2
                        }
                        else {
                            t--;
                            c1 = (t*(t-2) - 1)/-2;
                        }
                    	break;
					}
                }
                control = c1 < 1 ? c1 : 1;
//                Log.info(".animate: control = "+control, this);
                return control == 1.0;
            }
            control = 1;
            return true;
        }   
                            
        /**
         * Called at the start of the first call to animate().
         */
		protected function firstTime():void {
//            stime = alist.control.time;
        }       
    
        /** Swaps the starting and ending values. */
        override protected function swapEnds():void {
            super.swapEnds();
            if (easing != EASE_NONE && easing != EASE_BOTH) {
                easing = easing == EASE_IN ? EASE_OUT : EASE_IN;
            }
        }
    }
}