/*
* Playdom, Inc. (c)2013 All Rights Reserved
*/
package com.playdom.gas.interfaces 
{
	import com.playdom.gas.AnimList;
	import com.playdom.gas.parsing.ScriptTokenizer;
	
	import flash.display.DisplayObjectContainer;

	/**
	 * Processes XML data.
	 * 
	 * @author Rob Harris
	 */
	public interface IAnimParser
	{
		/**
		 * Recursively processes XML data.  
		 *
		 * @param list  The XML data.
		 */
		function parseScript(tokenizer:ScriptTokenizer, layer:DisplayObjectContainer = null):void; 
		
		function processChild(child:ScriptTokenizer):void;
	}
}