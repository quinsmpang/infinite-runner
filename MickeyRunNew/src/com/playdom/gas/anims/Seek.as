/*
* Playdom, Inc. (c)2013 All Rights Reserved
*/
package com.playdom.gas.anims 
{
	import com.playdom.gas.AnimList;
	
	import flash.text.TextField;
	
	/**
	 * Alters the integer text value of a display object over time.
	 * 
	 * @author Rob Harris
	 */
	public class Seek extends Normalizer	
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Starting value. */
		private var start:int;
		
		/** Ending value. */
		private var end:int;
		
		/** Leading zeros. */
		private var zeros:int;
		
		/** The text field to alter. */
		private var tf:TextField;
		
		/**
		 * Creates or reuses an instance of Seek.
		 * 
		 * @param start  The starting value.
		 * @param end    The ending value.
		 * @param wait   The number of milliseconds to wait before starting.
		 * @param dur    The number of milliseconds for the duration of the activity.
		 *   
		 * @return  A Seek object. 
		 */
		public static function make(alist:AnimList, start:int, end:int, wait:int, dur:int, zeros:int=0):Seek 
		{
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Seek = pool.pop();
			}
			else
			{
				anim = new Seek();
			}
			// initialize the variables
			anim.initNorm(wait, dur);
			anim.start = start;
			anim.end = end;
			anim.zeros = zeros;
			anim.tf = alist.dob as TextField;
			// add it to the parent list
			alist.add(anim);
			return anim;
		}   
		
		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the animation is complete. 
		 */
		override public function animate():Boolean 
		{
			var done:Boolean = super.animate();
			var n:int = start+((end-start)*control);
			if ( tf )
			{
				if ( zeros == 0 )
				{
					tf.text = n.toString();
				}
				else
				{
					tf.text = leadingZero( n.toString(), zeros );
				}
			}
			return done;
		}		
		
		/** Swaps the starting and ending values. */
		override protected function swapEnds():void 
		{
			super.swapEnds();
			var tmp:Number = start;
			start = end;
			end = tmp;
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
		 * Parses tokenized data to create an instance of this object.
		 *  
		 * @param tokenizer The script tokenizer.
		 * @param helper    The parser helper.
		 * @param context   The system context.
		 */
		public static function parse( tokenizer:Object, helper:Object, context:Object ):void
		{
			var anim:Seek = Seek.make(helper.alist,
				tokenizer.getInt("wait", 0),
				tokenizer.getInt("dur", 1000),
				tokenizer.getInt("start", 0),
				tokenizer.getInt("end", 100)
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
		public static function leadingZero(str:String, digits:int):String
		{
			for (var i:int = 0; i < digits-1; i++)
			{
				str = "0"+str;
			}
			return str.substr(str.length-digits);
		}
		
	}
}