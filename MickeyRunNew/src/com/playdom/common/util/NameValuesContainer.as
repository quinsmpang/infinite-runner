///////////////////////////////////////////////////////////
//  NameValuesContainer.as
//  Actionscript 3.0 of the Class NameValuesContainer
//  Property of Playdom
//  Created on:      25-Feb-2010 11:58:19 AM
//  Original author: Iman Khabazian
// Copyright © 2009-2010 Playdom, Inc. All rights reserved.
///////////////////////////////////////////////////////////

package com.playdom.common.util
{
	import com.playdom.common.interfaces.ILog;

	/**
	 * holds associative arrays name and value and can convert them to a string (by default url sytle name value pairs)
	 * Its very easy to add Pairs (from strings or objects, or other NVCs).
	 * @author Iman Khabazian
	 * @version 1.0
	 * @created 25-Feb-2010 11:58:19 AM
	 */
	public class NameValuesContainer
	{
	    /**
	     * amount of name value pairs.
	     */
	    private var _length:uint = 0;

		/**
	     * array of names
	     */
	    private var _names:Array  /* of String */ = [];
	    
		/**
	     * Array of values
	     */
	    private var _values:Array /* of String */ = [];
		
		private static var _instance:NameValuesContainer;
		
		/**
		 * Constructor
		 * 
		 * @param ...rest    List of Name, Value Strings for origanal object
		 */
		public function NameValuesContainer(...rest): void
		{
			var n:int = rest.length;
			for (var i: uint = 0; i<n;)
			{
				_names[_length] = rest[i++];
				_values[_length++] = rest[i++];
			}
		}
		
		/**
		 * Returns Name at a particular index. 
		 * @param index
		 * @return 
		 * 
		 */
		public function getNameAt(index:uint) : String
		{
			return _names[index];
		}
		
		/**
		 * Returns Value at a particular index. 
		 * @param index
		 * @return 
		 * 
		 */
		public function getValueAt(index:uint) : String
		{
			return _values[index];
		}

 		/**
	     * adds a name value pair to the container.
	     * 
	     * @param name
	     * @param value
	     * returns true if add went through
	     */
	    public function addPair(name:String, value:String): Boolean
	    {
	    	if ((name != "") && (value != ""))
	    	{
	    		_names[_length] = name;
		    	_values[_length++] = value;
		    	return true;
	    	}
	    	else return false;
	    }
	    
	     /**
	     * appends another NVC to this nvc     * 
	     * @param name
	     * @param value
	     */
	    public function addNVC(nvc:NameValuesContainer): void
	    {
	    	if (nvc)
			{
				var n:int = nvc.length;
	    		for (var i:uint = 0; i < n; i++)
	   		 	{
		    		_names[_length] = nvc.getNameAt(i);
			    	_values[_length++] = nvc.getValueAt(i);
	    		}
			}
	   	}
	    
	    /**
	     * Read only amount of name-value pairs.
	     */
	    public function get length(): uint
	    {
	    	return(_length);
	    }
		
		/**
	     * Shortcut function to get the instance without creating a new object.  Minimizes
	     * overhead associated with constructing a new object.
	     * 
	     */
	    static public function getScratch(...rest): NameValuesContainer
	    {
	    	if (_instance)
	    	{
	    		_instance._values = [];
		    	_instance._length = 0;
	    	}
	    	else
	    	{
	    		_instance = new NameValuesContainer();
	    	}
			var n:int = rest.length;
	    	for (var i:uint = 0; i < n;)
		    {
    			_instance._names[_instance._length] = rest[i++];
    			_instance._values[_instance._length++] = rest[i++]
		    } 
	    	return (_instance);
	    }
	
		/**
		 * add to NVC by pairs of strings, like constructor
		 * @param rest
		 * 
		 */
		public function addByPairs(...rest): void
		{
			var n:int = rest.length;
			for (var i: uint = 0; i < n;)
	    	{
	    		_names[_length] = rest[i++];
	    		_values[_length++] = rest[i++];
	    	}
		}

	    /**
	     * adds in information from other objects into NameValuesContainer.
	     * 
	     * @param obj
	     * @param title
	     */
	    public function addObject( obj:Object, log:ILog, title:String="" ): void
	    {
	    	if (title != "")
			{
				title+= "_";
			}
	    	for (var sKey:String in obj) 
	    	{
	    		if ((obj[sKey] is Number) || (obj[sKey] is String) || (obj[sKey] is uint) || (obj[sKey] is int))
	    			if ((obj[sKey] != "") && (obj[sKey]!=null))
	    			{
						_names[_length] = title + sKey;
		    			_values[_length++] = obj[sKey];
					}
	    			else 
	    			{
						log.warning("NVC.parseToNameValue rejected: " + _names[_length] + " val: " + obj[sKey]);
	    			}
	    		else
	    			addObject( obj[ sKey ], log, title );	
	    	}  	
	    }

	    /**
	     * returns a string representaion of name value pairs, ie &name1=value1&name2=value2&name3=value3"
	     * if either the name or value is empty this function will skip it.
	     */
	    public function toURL(): String
	    {
	    	var first:uint = 0;
	    	while ((_names[first] == "") || (_values[first] == "")) 
    		{
    			first++;
    		}
	    	if (length>first)
	    	{ 
				var retString: String = _names[first] + "=" + _values[first]
		    	for (var i: uint = 1; i < length; i++)
		    	{
		    		if ((_names[i] != "") && (_values[i] != "") && (_names[i] != null) && (_values[i] != null))
					{
						retString += "&" + _names[i] + "=" + _values[i];
					}
					else 
					{
						//Log.warn("NVC contains nulls or black strings");	
					}
	    		}
	    		return (retString);
	    	}
	    	else
	    	{
	    		// NVC is Empty
	    		return ("NVC is empty");
	    	}
		} // toURL
	}//NameValuesContainer
}// package