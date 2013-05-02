/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.common.recycle
{
	import com.playdom.common.interfaces.IDestroyable;

	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	/**
	 * A sprite that can be recycled for reuse.
	 */
	public class RecyclableSprite extends Sprite implements IDestroyable
	{
		public static var normalColorTransform:ColorTransform = new ColorTransform();

		/** The recycling pool */
		private static var pool:Array = [];

		/** Optional blur filter */
		public var blur:IDestroyable;

		public static function make(layer:DisplayObjectContainer=null):RecyclableSprite
		{
			// recycle or create an instance
			if (pool.length > 0)
			{
				var instance:RecyclableSprite = pool.pop();
			}
			else
			{
				instance = new RecyclableSprite();
			}

			// add to the parent layer
			if (layer)
			{
				layer.addChild(instance);
			}
			return instance;
		}

		/**
		 * Wraps a display object in a Sprite wrapper that allows an anchor
		 * point to be set.  If the optional anchor points are not provided,
		 * the center point is computed instead.
		 *
		 * @param dob The display object.
		 * @param x   Optional X anchor coordinate.
		 * @param y   Optional Y anchor coordinate.
		 *
		 * @return the wrapper Sprite
		 */
		public static function addAnchor(dob:DisplayObject, x:int=int.MIN_VALUE, y:int=int.MIN_VALUE):Sprite
		{
			var dx:int = -dob.width/2;
			var dy:int = -dob.height/2;
			if (x != int.MIN_VALUE)
			{
				dx = x;
				dy = y;
			}
			var spr:RecyclableSprite = RecyclableSprite.make(dob.parent);
			spr.addChild(dob);
			dob.x = dx;
			dob.y = dy;
			return spr;
		}

		/**
		 * Frees all resources for garbage collection.
		 */
		public function destroy():void
		{
			var len:int = this.numChildren;
			for (var i:int = len-1; i >= 0; i--)
			{
				var child:DisplayObject = removeChildAt(i);
				if (child is IDestroyable)
				{
					IDestroyable(child).destroy();
				}
			}
			if (parent)
			{
				parent.removeChild(this);
			}
			this.scaleX = this.scaleY = 1.0;
			this.alpha = 1.0;
			this.visible = true;
			this.filters = null;
			this.scrollRect = null;
			this.rotation = x = y = 0;
			if (blur)
			{
				blur.destroy();
				blur = null;
			}
			this.mask = null;
			this.transform.colorTransform = normalColorTransform;
			this.name = "*recycled*";
			this.blendMode = BlendMode.NORMAL;
			this.graphics.clear();
			this.buttonMode = false;
			this.mouseEnabled = true;
			this.mouseChildren = true;
			this.stopDrag();
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