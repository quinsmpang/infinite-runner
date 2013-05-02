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
	 * A primative shape that can be recycled for reuse.
	 */
	public class RecyclableShape extends Sprite	implements IDestroyable
	{
		/** The recycling pool */
		private static var pool:Array = [];

		/** Optional blur filter */
		public var blur:IDestroyable;

		private var type:String;
		private var currColor:uint;
		private var currAlpha:Number;
		private var w:int;
		private var h:int;

		public static function make(layer:DisplayObjectContainer, type:String, color:uint, alpha:Number, w:int, h:int):RecyclableShape
		{
			// recycle or create an instance
			if (pool.length > 0)
			{
				var instance:RecyclableShape = pool.pop();
				instance.graphics.clear();
			}
			else
			{
				instance = new RecyclableShape();
			}

			// initialize the variables
			instance.type = type;
			instance.currColor = color;
			instance.currAlpha = alpha;
			instance.x = 0;
			instance.y = 0;
			instance.w = w;
			instance.h = h;
			instance.scaleX = instance.scaleY = 1;

			// draw the shape
			instance.draw();

			// add to the parent layer
			if (layer)
			{
				layer.addChild(instance);
			}

			return instance;
		}

		/**
		 * Draw the shape.
		 *
		 * @param parms The starting parameters: color, alpha, parent, recycler.
		 */
		private function draw():void
		{
			graphics.beginFill(currColor, currAlpha);
			switch (type)
			{
				case "rect":
				{
					graphics.drawRect(0, 0, w, h);
					break;
				}
				case "oval":
				{
					graphics.drawEllipse(0, 0, w, h);
					break;
				}
				default:
				{
//					logger.info(".draw: unknown type: "+type, this);
				}
			}
			graphics.endFill();
		}

		public function set color(v:uint):void
		{
			currColor = v;
			draw();
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
			this.buttonMode = false;
			this.mouseChildren = true;
			this.mouseEnabled = true;
			this.scaleX = this.scaleY = 1.0;
			this.alpha = 1.0;
			this.visible = true;
			this.filters = null;
			this.rotation = 0;
			this.transform.colorTransform = RecyclableSprite.normalColorTransform;
			this.name = "*recycled*";
			this.blendMode = BlendMode.NORMAL;
			if (blur)
			{
				blur.destroy();
				blur = null;
			}
			this.mask = null;
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