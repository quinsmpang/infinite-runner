/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.common.util 
 {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	
	/**
	 * Static methods for centering a sprite.
	 *  
	 * @author rharris
	 */
	public class CenteringSprite {
		/**
		 * Centers a display object in its centering sprite wrapper. 
		 * 
		 * @param dob The display object.
		 */
		public static function recenter( dob:DisplayObject ):void
		{
			dob.x = -dob.width/2;
			dob.y = -dob.height/2;
		}
		
		/**
		 * Fetches a display object from a centering sprite wrapper. 
		 * 
		 * @param name  The centering wrapper's name.
		 * @param layer The parent container.
		 * 
		 * @return      The child display object.
		 */
		public static function getCenteredDisplayObject( name:String, layer:DisplayObjectContainer ):DisplayObject
		{
			return ( FindChild.byName( name, layer ) as DisplayObjectContainer ).getChildAt( 0 );
		}
		
		/**
		 * Sets new text then centers the TextField.
		 *  
		 * @param tf
		 * @param msg
		 */
		public static function setCenteredText( tf:TextField, msg:String ):void
		{
			tf.text = msg;
			recenter( tf );
		}
		
	}
}