/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.common.util 
 {
	import com.playdom.common.interfaces.IDestroyable;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * View utility methods; this is a static class.
	 */
	public class ViewUtils {
		
		/**
		 * Fetches an integer value from an Object used for parameter setting.
		 *  
		 * @param parms  The parameter object.
		 * @param key    The associated property key.
		 * @param def    The default value if no property found.
		 * @return       The integer value.
		 */
		public static function getIntParm(parms:Object, key:String, def:int=0):int {
			return parms[key] ? parms[key] : def;
		}
		
		/**
		 * Fetches a string value from an Object used for parameter setting.
		 *  
		 * @param parms  The parameter object.
		 * @param key    The associated property key.
		 * @param def    The default value if no property found.
		 * @return       The string value.
		 */		
		public static function getStringParm(parms:Object, key:String, def:String=""):String {
			return parms[key] ? parms[key] : def;
		}	
		
		/**
		 * Fetches a boolean value from an Object used for parameter setting.
		 *  
		 * @param parms  The parameter object.
		 * @param key    The associated property key.
		 * @param def    The default value if no property found.
		 * @return       The boolean value.
		 */					
		public static function getBooleanParm(parms:Object, key:String, def:Boolean=false):Boolean {
			return parms[key] != null ? parms[key] : def;
		}
		
		/**
		 * Creates a text display object.
		 *
		 * @param parms  The parameters stored as an anonymous object.
		 * @return A new text display object.
		 */
        public static function initDob(dob:DisplayObject, x:int, y:int, layer:Sprite):void
        {
			dob.x = x;
			dob.y = y;
			if (layer) 
			{
				layer.addChild(dob);
			}
		}
		
		public static function showChildByName( name:String, container:DisplayObjectContainer, show:Boolean ):void
		{
			var spr:DisplayObject = FindChild.byName( name, container );
			if ( spr )
			{
				spr.visible = show;
			}
		}
		
		/**
		 * Removes and destroys all children of a container.
		 *  
		 * @param container  The container.
		 */
		public static function destroyAllChildren( container:DisplayObjectContainer ):void
		{
			var num:int = container.numChildren;
			for (var i:int = 0; i < num; i++) 
			{
				var dob:DisplayObject = container.removeChildAt( 0 );
				if ( dob is DisplayObjectContainer )
				{
					destroyAllChildren( dob as DisplayObjectContainer );
				}
				if ( dob is IDestroyable )
				{
					IDestroyable( dob ).destroy();
				}
			}
		}
		
		public static function destroyDob( dob:DisplayObject ):void
		{
			if ( dob != null )
			{
				if ( dob is IDestroyable )
				{
					( dob as IDestroyable ).destroy();
				}
				else
				{
					dob.parent.removeChild( dob );
				}
			}
		}

		
		/**
		 * Removes all children of a container and it's subcontainers.
		 *  
		 * @param container  The container.
		 */
		public static function removeAllChildren( container:DisplayObjectContainer ):void
		{
			var num:int = container.numChildren;
			for (var i:int = 0; i < num; i++) 
			{
				var dob:DisplayObject = container.removeChildAt( 0 );
				if ( dob is DisplayObjectContainer )
				{
					removeAllChildren( dob as DisplayObjectContainer );
				}
			}
		}
		
		private static var spaces:String = "                                                   ";
		
		/**
		 * Logs all children of a container and it's subcontainers.
		 *  
		 * @param container  The container.
		 * @param indent     The current indent.
		 * @param visibleOnly True if only visible objects should be listed.
		 * 
		 * @return A string. 
		 */
		public static function logAllChildren( container:DisplayObjectContainer, visibleOnly:Boolean=false, indent:int=0 ):String
		{
			if ( container )
			{
				if ( !visibleOnly || container.visible )
				{
					var txt:String = describe( container, indent ) + "\n";
					indent += 2;
					var num:int = container.numChildren;
					for (var i:int = 0; i < num; i++) 
					{
						var dob:DisplayObject = container.getChildAt( i );
						if ( !visibleOnly || dob.visible )
						{
							if ( dob is DisplayObjectContainer )
							{
								txt += logAllChildren( dob as DisplayObjectContainer, visibleOnly, indent );
							}
							else
							{
								txt +=  describe( dob, indent ) + "\n";
							}
						}
					}
				}
				else
				{
					txt = "not visible";
				}
			}
			else
			{
				txt = "null";
			}
			return txt;
		}
		
		public static function describe( dob:DisplayObject, indent:int=0 ):String
		{
			var descr:String = spaces.substr( 0, indent ) + dob.name + " " + dob.x + "," + dob.y + " " + dob.width + "x" + dob.height;
			if ( dob.hasOwnProperty( "mouseChildren" ) )
			{
				descr += " mouseChildren=" + dob[ "mouseChildren" ]; 
			}
			if ( dob.hasOwnProperty( "mouseEnabled" ) )
			{
				descr += " mouseEnabled=" + dob[ "mouseEnabled" ]; 
			}
			return  dob ? descr : "null";
		}
		
		/**
		 * Moves a display object to the front of a container.
		 *  
		 * @param container The child's container.
		 * @param child     The child display object.
		 */
		public static function moveToFront(container:DisplayObjectContainer, child:DisplayObject):void {
			if (child != null && container.contains(child)) {
				container.setChildIndex(child, container.numChildren-1);
			}
		}

		/**
		 * Draws a bitmap into a sprite with scaling to fit.
		 *  
		 * @param sourceData  The source bitmap image.
		 * @param destSpr     The destination sprite.
		 * @param destRect    The destination area.
		 */
		public static function drawScaledBitmap(sourceData:BitmapData, destSpr:Sprite, destRect:Rectangle, tmpMatrix:Matrix):void {
			var scaleX:Number = destRect.width/sourceData.width;
			var scaleY:Number = destRect.height/sourceData.height;
			tmpMatrix.identity();
			tmpMatrix.scale(scaleX, scaleY);
			tmpMatrix.translate(destRect.x, destRect.y);
			
			destSpr.graphics.beginBitmapFill(sourceData, tmpMatrix, true, true);
			destSpr.graphics.drawRect(destRect.x, destRect.y, destRect.width, destRect.height);
			destSpr.graphics.endFill();			
		}	
			
		/**
		 * Moves a display object to a specific location.
		 *  
		 * @param dob  The display object.
		 * @param x    The x location.
		 * @param y    The y location.
		 */
		public static function move(dob:DisplayObject, x:int, y:int):void {
			dob.x = x;
			dob.y = y;
		}	
		
		/**
		 * Moves a display object to a specific location.
		 *  
		 * @param dob  The display object.
		 * @param w    The width.
		 * @param h    The height.
		 */
		public static function resize(dob:DisplayObject, w:int, h:int):void {
			dob.width = w;
			dob.height = h;
		}
		
		/**
		 * Toggles the visible property of a display object.
		 *  
		 * @param dob  The display object.
		 */
		public static function toggleVisible( dob:DisplayObject ):void
		{
			if ( dob )
			{
				dob.visible = !dob.visible;
			}
		}
		
		/**
		 * Copies a bitmap image from a source area to a destination area with scaling to fit.
		 *  
		 * @param sourceData  The source bitmap image.
		 * @param sourceRect  The source area.
		 * @param destData  The destination bitmap.
		 * @param destRect  The destination area.
		 */
		public static function copyScaleClip(sourceData:BitmapData, sourceRect:Rectangle, destData:BitmapData, destRect:Rectangle):void {
			var scaleX:Number=destRect.width/sourceRect.width;
			var scaleY:Number=destRect.height/sourceRect.height;
			var tmpData:BitmapData=new BitmapData(sourceRect.width, sourceRect.height, true, 0x00000000)
			tmpData.copyPixels(sourceData, sourceRect, new Point(0,0));
			var matrix:Matrix=new Matrix(scaleX, 0, 0, scaleY, destRect.x, destRect.y);
			destData.draw(tmpData, matrix, null, null, null , false);
		}
		
		private static var zeroPoint:Point = new Point(0, 0);
		private static var zeroMatrix:Matrix = new Matrix();
		
		/**
		 * Copies a portion of a bitmap image from a source area to a new BitmapData object.
		 *  
		 * @param sourceData  The source bitmap image.
		 * @param sourceRect  The source area.
		 * 
		 * @return  A new BitmapData object. 
		 */
		public static function copyBitmapData(sourceData:BitmapData, sourceRect:Rectangle):BitmapData 
		{
			var bmd:BitmapData = new BitmapData(sourceRect.width, sourceRect.height, true, 0x00000000);
			bmd.copyPixels(sourceData, sourceRect, zeroPoint);
			return bmd;
		}
		
		public static function setText(dobName:String, txt:String, top_layer:Sprite, parent:Sprite=null):void {
			if (parent == null) {
				parent = top_layer;
			}
			var dob:DisplayObject = parent.getChildByName(dobName);
			if (dob is TextField) {
				(dob as TextField).text = txt;
			}
		}	
			
		public static function setHtml(dobName:String, html:String, top_layer:Sprite, parent:Sprite=null):void {
			if (parent == null) {
				parent = top_layer;
			}
			var dob:DisplayObject = parent.getChildByName(dobName);
			if (dob is TextField) {
				(dob as TextField).htmlText = html;
			}
		}
		
		public static function makeBox(x:int, y:int, w:int, h:int, color:uint, alpha:Number, parent:Sprite=null):Sprite 
		{
			var spr:Sprite = new Sprite();
			spr.graphics.beginFill(color, alpha);
			spr.graphics.drawRect(0, 0, w, h);
			spr.graphics.endFill();
			move(spr, x, y);
			if (parent) {
				parent.addChild(spr);
			}
			return spr;
		}
				
		/**
		 * Draws a rectangle.
		 *  
		 * @param graphics  The graphics object.
		 * @param x         The left edge.
		 * @param y         The top edge.
		 * @param w         The width.
		 * @param h         The height.
		 * @param color     The color.
		 * @param alpha     The alpha value.
		 */
		public static function drawRect(graphics:Graphics, x:int, y:int, w:int, h:int, color:uint, alpha:Number=1, corner:int=0):void 
		{
			graphics.beginFill(color, alpha);
			if (corner > 0) {
				graphics.drawRoundRect(x, y, w, h, corner, corner);
			}
			else {
				graphics.drawRect(x, y, w, h);
			}
			graphics.endFill();			
		}	
		
		public static function makeLayer(name:String, parent:Sprite, mouse:Boolean=false ):Sprite 
		{
			var layer:Sprite = new Sprite();
			layer.name = name;
			layer.mouseEnabled = mouse;
			parent.addChild(layer);     
			return layer;   
		} 
		
		public static function makeCenteringSprite(child:DisplayObject):Sprite 
		{
			var parent:DisplayObjectContainer = child.parent;
			var spr:Sprite = new Sprite();
			spr.name = "centerer";
//			spr.x = child.x;
//			spr.y = child.y;
//			spr.x = 0;
//			spr.y = 0;
			spr.addChild(child);   
			child.x = -child.width/2;
			child.y = -child.height/2;
//			child.x = 0;
//			child.y = 0;
			if (parent)
			{
				parent.addChild(spr);
			}
			return spr;   
		}
		
		/**
		 * Shows or hides a named child of a Sprite.
		 *  
		 * @param parent  The parent Sprite.
		 * @param visible True to show the child.
		 * @param name    The name of the child
		 * 
		 * @return The child or null if not found. 
		 */
		public static function showChild( parent:Sprite, visible:Boolean, name:String ):DisplayObject
		{
			if ( parent )
			{
				var icon:DisplayObject = FindChild.byName( name, parent );
				if ( icon )
				{
					icon.visible = visible;
				}
			}
			return icon;
		}

		/**
		 * Sets the text of a named TextField child of a Sprite. The child is also made visible.
		 *  
		 * @param parent    The parent Sprite.
		 * @param label     The text.
		 * @param labelName The name of the child (optional: "textField" is used by default)
		 * 
		 * @return The child or null if not found. 
		 */
		public static function setChildText( parent:Sprite, label:String, labelName:String="textField" ):void
		{
			if ( parent && label != null )
			{
				var tf:TextField = FindChild.byName( labelName, parent ) as TextField;
				if ( tf )
				{
					tf.text = label;
					tf.visible = true;
				}
			}
		}
		
		
		public static function chechBoundingBox( box:Rectangle, x:Number, y:Number ):Boolean
		{
			return box.left <= x &&  box.right >= x && box.top <= y && box.bottom >=y; 
		}
		
	}
}