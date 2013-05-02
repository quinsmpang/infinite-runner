/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.common.recycle
{
	import com.playdom.common.interfaces.IDestroyable;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
    
	/**
	 * A text display object that can be recycled for reuse.
	 */
	public class RecyclableTextField extends TextField implements IDestroyable
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		/** Optional blur filter */
		public var blur:IDestroyable;
		
		public static function make(text:String, color:uint, size:uint, layer:DisplayObjectContainer, font:String="Arial"):RecyclableTextField
		{
			// recycle or create an instance
			if (pool.length > 0)
			{
				var instance:RecyclableTextField = pool.pop();
			}
			else
			{
				instance = new RecyclableTextField();
			}
			
			// initialize the instance variables
			instance.visible = true;
			instance.selectable = false;
			instance.wordWrap = false;
			instance.autoSize = TextFieldAutoSize.LEFT;
			instance.background = false;
			instance.border = false;
//			instance.embedFonts = true;
//			var fmt:TextFormat = new TextFormat("Arial", size);
			var fmt:TextFormat = new TextFormat(font, size);
			fmt.bold = false;
			fmt.align = TextFormatAlign.LEFT;
			instance.defaultTextFormat = fmt;
			instance.multiline = false;
			instance.textColor = color;
			instance.text = text == null ? "" : text;
			instance.x = instance.y = 0;
			
			// add to the parent layer
			if ( layer )
			{
				layer.addChild(instance);
			}
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
			this.rotation = 0;
			if (blur)
			{
				blur.destroy();
				blur = null;
			}
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