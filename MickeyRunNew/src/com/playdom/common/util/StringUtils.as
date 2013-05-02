/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.common.util {
 	import flash.text.TextField;
 	

	/**
	 * 	String utility methods; this is a static class.
	 */
	public class StringUtils 
	{
        /** List of characters to replace with white space. */
		private static const REPLACEMENTS:Object={"\n":"", "\r":"", "\t":"", "\f":"", "\v":"", " ":""};

		/**
		 * Replace all occurances of txt1 with txt2.
		 *
		 * @param txt  The text to be corrected.
		 * @param txt1 The text to be replaced.
		 * @param txt2 The replacement text.
		 * 
		 * @return The corrected text.
		 */
		public static function replace( txt:String, txt1:String, txt2:String ):String 
		{
			while ( txt.indexOf( txt1 ) != -1 ) 
			{
				txt = txt.replace( txt1, txt2 );
			}
			return txt;
		}											
		
		/**
		 * Fixes backslashes in text.
		 *
		 * @param txt  The text to be corrected.
		 * @return The corrected text.
		 */
		public static function fixBackslashes(txt:String):String {
			while (txt.indexOf("\\n") != -1) {
				txt = txt.replace("\\n", "\n");
			}
			return txt;
		}	
					
		/**
		 * Returns the correct plural suffix based on an amount.
		 *
		 * @param amount  The amount.
		 * @return The correct suffix.
		 */
		public static function plural(amount:int):String {
			return amount == 1 ? "" : "s";
		}
		
		public static function removeAllWhitespace(message:String):String {
			var pattern:RegExp;
			for (var key:String in REPLACEMENTS){
				pattern=new RegExp(key, "g");
				message = message.replace(pattern, REPLACEMENTS[key]);
			}
			return message;
		}
		
		public static function getStackTrace():String {
			var tempError:Error = new Error();
			return tempError.getStackTrace();				
		}
		
//		public static function makeTimeString(secs:int):String
//		{
//			var str:String = "";
//			var mins:int = secs/60;
//			secs = secs-mins*60;
//			var hrs:int = mins/60;
//			mins = mins-hrs*60;
//			if (hrs > 0)
//			{
//				str += hrs+":";
//			}
//			str += leadingZero(mins.toString(), 2)+":"+leadingZero(secs.toString(), 2);
//			return str;
//		}
		
		public static function leadingSpaces(str:String, length:int):String
		{
			for (var i:int = 0; i < length-1; i++)
			{
				str = " "+str;
			}
			return str.substr(str.length-length);
		}
		
		public static function leadingZero(str:String, digits:int):String
		{
			for (var i:int = 0; i < digits-1; i++)
			{
				str = "0"+str;
			}
			return str.substr(str.length-digits);
		}
		
		public static function addEllipsis(tf:TextField, maxw:int):void {
			var str:String = tf.text;			
			while (tf.textWidth > maxw) {
				str = str.substr(0, str.length-1);
				tf.text = str+"...";
			}
		}
		
		/**
		 * Inserts txt1 into txt at the specified index
		 *
		 * @param txt  The text to be corrected.
		 * @return The corrected text.
		 */
		public static function insert(txt:String, index:int, txt1:String):String {
			var idx:int = index;
			
			if (idx < txt.length) {
				if (idx < 0) {
					idx = 0;
				}
				
				var prefix:String = txt.slice(0, idx);
				var postfix:String = txt.slice(idx);
				
				return prefix + txt1 + postfix;
			}
			else {
				// this is really just an append..
				return txt + txt1;
			}
		}
		
//		/**
//		 * Trims the white space from the start and end of the line.
//		 *  
//		 * @param txt The text to be trimmed.
//		 * 
//		 * @return  The trimmed text. 
//		 */
//		public static function trim(txt:String):String 
//		{
//			if (txt != null) 
//			{
//				return txt.replace(/^\s+|\s+$/g, '');
//			}
//			return ''; 
//		}

		/**
		 * Removes quotes froma string, if they exist.
		 *  
		 * @param str  The string to examine.
		 * 
		 * @return The sring with no quotes. 
		 */
		public static function removeQuotes( str:String ):String
		{
			if ( str.indexOf( '"' ) == 0 )
			{
				str = str.substring( 1, str.length - 1);
			}
			return str;
		}
		
		/**
		 * Trims the white space from the start and end of the line.
		 *  
		 * @param txt The text to be trimmed.
		 * 
		 * @return  The trimmed text. 
		 */
		public static function JSONobjectToString(obj:Object):String 
		{
			if ( obj is String )
			{
				return obj as String;
			}
			var str:String = "{";
			var prefix:String = "";
			for (var key:String in obj)
			{
				str += prefix + '"' + key + '":"' + JSONobjectToString( obj[key] ) + '"';
				prefix = ",";
			}
			return str+"}"; 
		}
		
		/**
		 * Returns an array as a comma-separated string.
		 *  
		 * @param txt The text to be trimmed.
		 * 
		 * @return  The trimmed text. 
		 */
		public static function arrayToString( arr:Array, delim:String="," ):String 
		{
			var str:String = "";
			var prefix:String = "";
			for (var i:int = 0; i < arr.length; i++) 
			{
				str += prefix + arr[ i ].toString();
				prefix = delim;
			}
			return str; 
		}
		
	}
}