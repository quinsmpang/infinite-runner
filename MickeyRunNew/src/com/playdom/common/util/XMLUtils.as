/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.common.util 
 {
	/**
	 * A collection of static XML utility methods.
	 * 
	 * @author Rob Harris
	 */
	public class XMLUtils 
	{
		/**
		 * Parses an attribute of an XML object for a hex value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the value to parse.
		 * @param def The default value to use if the parse fails.
		 * @return The best hex value.
		 */
		public static function parseHexXML(xml:XML, key:String, def:uint):uint 
		{
			var val:XMLList = xml.attribute(key);
			if (val.length() == 0) 
			{
				return def;
			}
			return parseInt(val, 16);
		}
		
		/**
		 * Parses an attribute of an XML object for an integer value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the value to parse.
		 * @param def The default value to use if the parse fails.
		 * @return The best integer value.
		 */
		public static function parseIntXML(xml:XML, key:String, def:int):int 
		{
			var val:XMLList = xml.attribute(key);
			if (val.length() == 0) 
			{
				return def;
			}
			return parseInt(val);
		}	
			
		/**
		 * Parses an attribute of an XML object for an integer value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the value to parse.
		 * @param def The default value to use if the parse fails.
		 * @return The best integer value.
		 */
		public static function parseNumberXML(xml:XML, key:String, def:Number):Number 
		{
			var val:XMLList = xml.attribute(key);
			if (val.length() == 0) 
			{
				return def;
			}
			return parseFloat(val);
		}
		
		/**
		 * Parses an attribute of an XML object for a text value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the text value.
		 * @param def The default value to use if the attribute cannot be found.
		 * @return The best text value.
		 */
		public static function parseStringXML(xml:XML, key:String, def:String):String 
		{
			if ( xml )
			{
				var val:XMLList = xml.attribute(key);
				if (val.length() == 0) 
				{
					return def;
				}
				var attr:String = val.toString();
				return attr;
			}
			return def;
		}
		
		/**
		 * Parses an attribute of an XML object for a boolean value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the boolean value.
		 * @param def The default value to use if the attribute cannot be found.
		 * @return The best boolean value.
		 */
		public static function parseBooleanXML(xml:XML, key:String, def:Boolean):Boolean 
		{
			if ( xml )
			{
				var val:XMLList = xml.attribute(key);
				if (val.length() == 0) 
				{
					return def;
				}
				return val.toString() == "true";
			}
			return def;
		}

		/**
		 * Fetches a definition object from a list.
		 *  
		 * @param type The type associated withe the definition.
		 * @param list The list containing the definition object.
		 * 
		 * @return The definition object or null if not found.
		 */
		public static function getXMLDef(type:String, xml:Object):XML
		{
			var list:XMLList = xml == null ? null : xml.child(type); 
			return list == null || list.length() < 1 ? null : list[0];
		}
		
	}
}