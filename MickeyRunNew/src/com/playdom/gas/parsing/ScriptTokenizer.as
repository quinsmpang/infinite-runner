/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.parsing 
 {
 	import com.playdom.common.interfaces.ILog;
 	import com.playdom.common.util.Hashtable;

	/**
	 * Tokenizes a script; see this class's subclasses for a particular format (XML, JSON).  
	 * 
	 * A tokenizer represents an element that has a tag and a collection of attributes.  The element 
	 * can also have a list of children that are represented as unique tokenizers.
	 * 
	 * @author Rob Harris
	 */
	public class ScriptTokenizer extends Object
	{
		/** The message logger. */
		protected var log:ILog;
		
		/* The animation system variable hastable */
		protected var animVars:Hashtable;
		
		/**
		 * Initializes the tokenizer.
		 */
		public function init(aVars:Hashtable, log:ILog):void
		{
			this.animVars = aVars;
			this.log = log;
		}
		
		/**
		 * The source string to be parsed.
		 */
		public function set source(txt:String):void
		{	// see subclass implementation
		}
		
		/**
		 * The data object to be parsed.
		 */
		public function get data():Object
		{
			return null;	// see subclass implementation
		}
		
		/**
		 * The script format type.
		 */
		public function get formatType():String
		{
			return null;	// see subclass implementation
		}
		
		/**
		 * Frees all resources for garbage collection.
		 */
		public function destroy():void
		{
			log = null;
			animVars = null;
		}
		
		/**
		 * Fetches the tag name for this tokenizer.
		 *  
		 * @return The tag name. 
		 */
		public function getTag():String
		{
			return null;	// see subclass implementation
		}
		
		/**
		 * Fetches the value associated with an attribute key.
		 *  
		 * @param key The attribute key.
		 * 
		 * @return The associated value. 
		 */
		public function getAttribute(key:String):String
		{
			return null;	// see subclass implementation
		}
		
		/**
		 * Fetches the number of children belonging to this tokenizer.
		 *  
		 * @return The number of children. 
		 */
		public function getNumChildren():int
		{
			return 0;	// see subclass implementation
		}
		
		/**
		 * Fetches an array of tokenizers where each is a child of this tokenizer.
		 *  
		 * @return The array of children tokenizers. 
		 */
		public function getChildren():Array
		{
			return null;	// see subclass implementation
		}
		
		/**
		 * Parses an attribute for an integer value.
		 *
		 * @param key The attribute key associated with the value to parse.
		 * @param def The default value to use if the parse fails.
		 * @return The best integer value.
		 */
		public function getInt(key:String, def:int):int
		{
			var varName:String = null;
			var result:int = def;
			var val:String = getAttribute(key);
			while (val && val.length > 0) 
			{
				var ch:String = val.charAt(0);
				if (ch == '%')
				{
					var idx:int = val.indexOf("=");
					if (idx != -1)
					{
						varName = val.substring(1, idx);
						val = val.substr(idx+1);
					}
					else
					{
						var delta:int = 0;
						val = val.substr( 1 );
						var opIdx:int = val.indexOf( "+" );
						if ( opIdx != -1 )
						{
							delta = parseInt( val.substr( opIdx + 1 ) );
							val = val.substring( 0, opIdx );
						}
						opIdx = val.indexOf( "-" );
						if ( opIdx == 0 )
						{
							result = -1 * parseInt( processValue( getSetting( val.substr( 1 ), "0" ), "0") );
							break;
						}
						else if ( opIdx != -1 )
						{
							delta = -1 * parseInt( val.substr( opIdx + 1 ) );
							val = val.substring( 0, opIdx );
						}
						result = delta + parseInt( processValue( getSetting( val, "0" ), "0") );
						break;
					}
				}
				else if (ch == '~')
				{
					result = Math.floor(randomValue(val));
					break;
				}
				else if (ch == '[')
				{
					result = parseInt(randomSet(val));
					break;
				}
				else
				{
					result = parseInt(val);
					break;
				}
			}
			if (varName)
			{
				animVars.setString(varName, result.toString());
			}
			return result;
		}
		
		/**
		 * Parses an attribute of an XML object for a text value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the text value.
		 * @param def The default value to use if the attribute cannot be found.
		 * @return The best text value.
		 */
		public function getString(key:String, def:String):String 
		{
			return processValue(getAttribute(key), def);
		}
		
		/**
		 * Parses an attribute of an XML object for a text value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the text value.
		 * @param def The default value to use if the attribute cannot be found.
		 * @return The best text value.
		 */
		public function processValue(val:String, def:String):String 
		{
			var result:String = def;
			var varName:String = null;
			while (val && val.length > 0)
			{
				var ch:String = val.charAt(0);
				if (ch == '%')
				{
					// variable
					var idx:int = val.indexOf("=");
					if (idx != -1)
					{
						varName = val.substring(1, idx);
						val = val.substr(idx+1);
					}
					else
					{
						result = processValue( getSetting( val.substr( 1 ), "" ), def );
						break;
					}
				}
				else if (ch == '~')
				{
					result = Math.floor(randomValue(val)).toString();
					break;
				}
				else if (ch == '[')
				{
					result = randomSet(val);
					break;
				}
				else
				{
					result = val;
					break;
				}
			}
			if (varName)
			{
				animVars.setString(varName, result);
			}
			return result;
		}
		
		/**
		 * Parses an attribute of an XML object for a floating point value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the value to parse.
		 * @param def The default value to use if the parse fails.
		 * @return The best integer value.
		 */
		public function getNumber(key:String, def:Number):Number 
		{
			var varName:String = null;
			var result:Number = def;
			var val:String = getAttribute(key);
			while (val && val.length > 0) 
			{
				var ch:String = val.charAt(0);
				if (ch == '%')
				{
					var idx:int = val.indexOf("=");
					if (idx != -1)
					{
						varName = val.substring(1, idx);
						val = val.substr(idx+1);
					}
					else
					{
						result = parseFloat(getSetting(val.substr(1), "0"));
						break;
					}
				}
				else if (ch == '~')
				{
					result = randomValue(val);
					break;
				}
				else if (ch == '[')
				{
					result = parseFloat(randomSet(val));
					break;
				}
				else
				{
					result = parseFloat(val);
					break;
				}
			}
			if (varName)
			{
				//				vars[varName] = result.toString();
				animVars.setString(varName, result.toString());
			}
			return result;
		}	
		
		/**
		 * Parses an attribute of an XML object for a boolean value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the value to parse.
		 * @param def The default value to use if the parse fails.
		 * 
		 * @return The best integer value.
		 */
		public function getBoolean(key:String, def:Boolean):Boolean 
		{
			var varName:String = null;
			var result:Boolean = def;
			var val:String = getAttribute(key);
			while (val && val.length > 0) 
			{
				var ch:String = val.charAt(0);
				if (ch == '%')
				{
					var idx:int = val.indexOf("=");
					if (idx != -1)
					{
						varName = val.substring(1, idx);
						val = val.substr(idx+1);
					}
					else
					{
						result = getSetting(val.substr(1), "") == "true";
						break;
					}
				}
				else if (ch == '~')
				{
					result = Math.random()*2 < 1;
					break;
				}
				else if (ch == '[')
				{
					val = randomSet(val);
					result = val == "true" || val == "1";
					break;
				}
				else
				{
					result = val == "true" || val == "1";
					break;
				}
			}
			if (varName)
			{
				//				vars[varName] = result ? "true" : "false";
				animVars.setString(varName, result ? "true" : "false");
			}
			return result;
		}	
		
		/**
		 * Parses an attribute of an XML object for an integer value.
		 *
		 * @param xml The XML object.
		 * @param key The attribute key associated with the value to parse.
		 * @param def The default value to use if the parse fails.
		 * @return The best integer value.
		 */
		public function getHex(key:String, def:uint):uint 
		{
			var varName:String = null;
			var result:uint = def;
			var val:String = getAttribute(key);
			while (val && val.length > 0) 
			{
				var ch:String = val.charAt(0);
				if (ch == '%')
				{
					var idx:int = val.indexOf("=");
					if (idx != -1)
					{
						varName = val.substring(1, idx);
						val = val.substr(idx+1);
					}
					else
					{
						val = getSetting(val.substr(1), "0");
						result = parseInt(val, 16);
						break;
					}
					
				}
				else if (ch == '[')
				{
					result = parseInt(randomSet(val), 16);
					break;
				}
				else
				{
					result = parseInt(val, 16);
					break;
				}
			}
			if (varName)
			{
				//				vars[varName] = result.toString(16);
				animVars.setString(varName, result.toString(16));
			}
			return result;
		}	
		
		private function getSetting(key:String, def:String):String
		{
			var value:String = def;
			if (key)
			{
				value = animVars.getString(key, def);
			}
			return value;
		}
		
		/**
		 * Randomly picks from a comma-separated set
		 *  
		 * @param val  The set string.
		 * 
		 * @return One item from the set.
		 */
		private function randomSet(val:String):String 
		{
			var len:int = val.length;
			var arr:Array = val.substring(1, len-1).split(",");
			var rnd:int = Math.random()*arr.length;
			return arr[rnd];
		}
		
		/**
		 * Randomly picks from a range of numbers
		 *  
		 * @param val  The set string.
		 * 
		 * @return One item from the set.
		 */
		private function randomValue(val:String):Number 
		{
			var idx:int = val.indexOf("_");
			var len:int = val.length;
			var min:Number = parseFloat(val.substring(1, idx));
			var max:Number = parseFloat(val.substring(idx+1, len));
//			var rnd:Number = Math.random() * ( max - min + 1 ) + min;
			var rnd:Number = Math.random() * ( max - min ) + min;
			return rnd;
		}

	}
}