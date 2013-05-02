/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.common.recycle
{
	import com.playdom.common.interfaces.IBitmaps;
	import com.playdom.common.interfaces.IDestroyable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;

	/**
	 * A bitmap image that can be recycled for reuse.
	 */
	public class RecyclableBitmap extends Bitmap implements IDestroyable
	{
		/** The recycling pool */
		private static var pool:Array = [];

		/** Optional blur filter */
		public var blur:IDestroyable;

		/**
		 * Creates or recycles an instance of this class.
		 */
		public static function make(imageKey:String, layer:DisplayObjectContainer, assets:IBitmaps):RecyclableBitmap
		{
			// recycle or create an instance
			if (pool.length > 0)
			{
				instance = pool.pop();
			}
			else
			{
				var instance:RecyclableBitmap = new RecyclableBitmap();
			}

			// initialize the variables and add to the parent layer
			if ( imageKey )
			{
				instance.bitmapData = assets ? assets.getBitmapData(imageKey) : null;
			}
			if (layer)
			{
				layer.addChild(instance);
			}
			instance.scaleX = instance.scaleY = 1;
			instance.rotation = instance.x = instance.y = 0;
			instance.alpha = 1;
			instance.visible = true;
			return instance;
		}

		/**
		 * Frees all resources for garbage collection.
		 */
		public function destroy():void
		{
			if (parent)
			{
				parent.removeChild(this);
			}
			this.filters = null;
			if (blur)
			{
				blur.destroy();
				blur = null;
			}
			if (mask is IDestroyable)
			{
				IDestroyable(mask).destroy();
			}

			this.bitmapData = null;

			this.mask = null;
			this.transform.colorTransform = RecyclableSprite.normalColorTransform;
			this.name = "*recycled*";
			this.blendMode = BlendMode.NORMAL;
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