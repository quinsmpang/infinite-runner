/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.gas.parsing 
{
	/**
	 * Provides access to key/value pairs within a JSON string.
	 *  
	 * @author Rob Harris
	 */
	public class JSONTokenizer
	{		
		/** Recycling pool */
		private static var pool:Array = [];

		/** The full JSON string. */
		private var json:String;
		
		/** An array of indexes to each token. */
		private var indexes:Array = [];
		
		/** The current index into the array of token indexes. */
		private var idx:int;
		
		/**
		 * Creates an instance of this class; the static make() method should be used instead to support recycling. 
		 */
		public function JSONTokenizer() 
		{
		}
		
		/**
		 * Returns an initialized instance of this class; recycling is supported.
		 *  
		 * @param json  The JSON string to be parsed.
		 * 
		 * @return The tokenizer.
		 */
		public static function make(json:String):JSONTokenizer
		{
			var jt:JSONTokenizer = pool.length > 0 ? pool.pop() : new JSONTokenizer()
			jt.init(json);
			return jt;
		}	
		
		/**
		 * Releases all resources and returns this instance to the recycling pool. 
		 */
		public function destroy():void
		{
			json = null;
			indexes.length = 0;
			pool.push(this);
		}
		
		/**
		 * Initialize the tokenizer.
		 * 
		 * @param json  The JSON string.
		 */
		private function init(json:String):void
		{
			this.json = json;
			
			var i:int = 0;
			indexes[i] = json.indexOf("{");
			while (indexes[i] != -1 && indexes[i] < json.length)
			{
				indexes[i+1] = json.indexOf(":", indexes[i]);
				i++;
				
				var i0:int = json.indexOf("\"", indexes[i]);
				var i1:int = json.indexOf(",", indexes[i]);
				if (i0 > 0 && i0 < i1)
				{	// adjust for quotes
					i1 = json.indexOf("\"", i0+1);
					indexes[i+1] = i1 == -1 ? -1 : i1+1;
				}
				else
				{
					indexes[i+1] = i1;
				}
				i++;
			}
			indexes[i] = json.indexOf("}", indexes[i-1]);
			idx = 0;
		}	
		
		/**
		 * Fetches the next property key.
		 *  
		 * @return The property key.
		 */
		public function nextKey():String
		{
			var ret:String = null;
			if (idx < indexes.length-1)
			{
				ret = json.substring(indexes[idx]+1, indexes[idx+1]);
			}
			return ret;
		}
		
		/**
		 * Fetches the next property value and advances the tokenizer to the next key/value pair.
		 *  
		 * @return The property value.
		 */
		public function nextInt():int
		{
			return parseInt(nextValue());
		}
		
		/**
		 * Fetches the next property value and advances the tokenizer to the next key/value pair.
		 *  
		 * @return The property value.
		 */
		public function nextValue():String
		{
			var ret:String = null;
			if (idx < indexes.length-1)
			{
				if (json.charAt(indexes[idx+1]+1) == "\"")
				{	// remove surrounding quotes
					ret = json.substring(indexes[idx+1]+2, indexes[idx+2]-1);
				}
				else
				{
					ret = json.substring(indexes[idx+1]+1, indexes[idx+2]);
				}
				idx += 2;
			}
			return ret;
		}
		
		/**
		 * Fetches a property value associated with a key and sets the tokenizer to the next key/value pair.
		 *  
		 * @param key  The property key.
		 * 
		 * @return     The property value.
		 */
		public function findValue(key:String, def:String=null):String
		{
			for (var i:int = 0; i < indexes.length-1; i += 2)
			{
				if (json.substring(indexes[i]+1, indexes[i+1]) == key)
				{
					idx = i;
					return nextValue();
				}
			}
			return def;
		}
		
		/**
		 * Determines if there are more key/value pairs to iterate.
		 *  
		 * @return  True if there are more elements. 
		 */
		public function hasMoreElements():Boolean
		{
			return idx < indexes.length-1;
		}
	}
}
