/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.common.recycle
{
	import com.playdom.common.interfaces.IDestroyable;
	
	import flash.filters.BlurFilter;
    
	/**
	 * A blur filter that can be recycled for reuse.
	 */
	public class RecyclableBlur extends Object	implements IDestroyable
	{
		/** The recycling pool */
		private static var pool:Array = [];

		/** The blur filter */
		private var filter:BlurFilter;
		
		/** The array wrapper */
		public var array:Array;
		
		/**
		 * Creates an instance of this class.
		 */
        public function RecyclableBlur()
		{
			filter = new BlurFilter();
			array = [filter];
		}
		
		public static function make():RecyclableBlur
		{
			// recycle or create an instance
			if (pool.length > 0)
			{
				var instance:RecyclableBlur = pool.pop();
			}
			else
			{
				instance = new RecyclableBlur();
			}
			return instance;
		}
		
		/**
		 * Frees all resources for garbage collection.
		 */
		public function setBlur(v:Number):void
		{
			filter.blurX = filter.blurY = v;
		}
		
		/**
		 * Frees all resources for garbage collection.
		 */
		public function destroy():void
		{
			if ( RecycleRef.RECYClING )
			{
				if (pool.indexOf(this) == -1) 
				{
					pool.push(this);
				}
			}
		}
	}
}