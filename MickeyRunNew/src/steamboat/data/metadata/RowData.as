/*
* Playdom, Inc. (c)2013 All Rights Reserved
*/
package steamboat.data.metadata
{
	public class RowData 
	{
		/** The object containing the configuration key / value pairs. */
		public var values:Object = {};
		public var tags:Array;
		public var uid:String;
		
		/**
		 * Fetches an object associated with a key.
		 *
		 * @param columnId  The column ID.
		 * @param def  The default value (optional).
		 * @return  The associated object.
		 */
		public function getObject( columnId:String="value", def:Object=null ):Object 
		{
			var val:Object = columnId ? values[ columnId ] : null;
			if ( val is RowData )
			{
				return val.getObject( "value", def );
			}
			return val ? val : def;
		}
		
		/**
		 * Fetches an array associated with a key.
		 *
		 * @param columnId  The column ID.
		 * @param def  The default value (optional).
		 * @return  The associated array.
		 */
		public function getArray( columnId:String="value", def:Array=null ):Array 
		{
			var val:Object = columnId ? getObject( columnId ) : null;
			return val ? val as Array : def;
		}
		
		/**
		 * Fetches a string value associated with a key.
		 *
		 * @param key  The key.
		 * @param def  The default value (optional).
		 * @return  The associated value.
		 */
		public function getString(columnId:String="value", def:String=null):String 
		{
			var val:Object = columnId ? getObject( columnId ) : null;
			return val ? val as String : def;
		}   
		
		/**
		 * Fetches a boolean value associated with a key.
		 *
		 * @param key  The key.
		 * @param def  The default value (optional).
		 * @return  The associated value.
		 */
		public function getBoolean(columnId:String="value", def:Boolean=false):Boolean 
		{
			var val:Object = columnId ? getObject( columnId ) : null;
			return val ? val == "1" || val == "true" : def;
		}
		
		/**
		 * Fetches an integer value associated with a key.
		 *
		 * @param key  The component's name.
		 * @param def  The default value (optional).
		 * @return  The component's current value.
		 */
		public function getInt(columnId:String="value", def:int=0):int 
		{
			var val:Object = columnId ? getObject( columnId ) : null;
			if ( val != null )
			{
				try
				{
					return int( val );
				}
				catch (e:Error) {}
			}
			return def;
		}
		
		/**
		 * Fetches an floating point value associated with a key.
		 *
		 * @param key  The component's name.
		 * @param def  The default value (optional).
		 * @return  The component's current value.
		 */
		public function getNumber(columnId:String="value", def:Number=0):Number 
		{
			var val:Object = columnId ? getObject( columnId ) : null;
			if ( val )
			{
				try
				{
					return Number( val );
				}
				catch (e:Error) {}
			}
			return def;
		}
		
		private const EMPTY_ARR:Array = [];
		
		public function hasTag( tag:String ):Boolean
		{
			if ( tags == null )
			{
				tags = getObject( "tags", EMPTY_ARR ) as Array;
			}
			return tags ? tags.indexOf( tag ) != -1 : false;
		}
		
	}
}