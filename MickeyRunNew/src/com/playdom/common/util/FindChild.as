/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.common.util 
 {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	
	/**
	 * Static methods for recursively locating a display object.
	 *  
	 * @author rharris
	 */
	public class FindChild 
	{
		/**
		 * Finds a child by name recursively. 
		 * 
		 * @param name  The child's name.
		 * @param layer The layer to search.
		 * 
		 * @return  The child or null if not found.
		 */
		public static function byName( name:String, layer:DisplayObjectContainer ):DisplayObject
		{
			var dob:DisplayObject;
			if ( name && layer )
			{
				dob = layer.getChildByName( name );
				if ( !dob ) 
				{
					for (var i:int = 0; i < layer.numChildren && dob == null; i++) 
					{
						var child:DisplayObject = layer.getChildAt( i );
						if ( child is DisplayObjectContainer && !( child is Loader ) ) 
						{
							dob = byName( name, child as DisplayObjectContainer );
						}
					}
				}
			}
			return dob;
		}
		
		
		/**
		 * Finds a children by name recursively. 
		 * 
		 * @param name  The children's name.
		 * @param layer The layer to search.
		 * 
		 * @return  The children (Vector.<DisplayObject>) or null if not found.
		 */
		public static function byNameWithDuplicates( name:String, layer:DisplayObjectContainer , result:Vector.<DisplayObject> = null):Vector.<DisplayObject>
		{
			if ( name && layer )
			{
				var len:int = layer.numChildren;
				for (var i:int = 0; i < len; i++)
				{
					var child:Object = layer.getChildAt(i);
					if ( child.name == name )
					{
						if( result == null )
						{
							result = new Vector.<DisplayObject>();
						}	
						result.push(child);
					}
					if (child is DisplayObjectContainer && !( child is Loader ) )
					{
						result = byNameWithDuplicates( name, child as DisplayObjectContainer, result);
					}
				}
			}
			return result;
		}
		
		public static function countDuplicates( name:String, layer:DisplayObjectContainer ):int
		{
			var count:int = 0;
			if ( name && layer )
			{
				var len:int = layer.numChildren;
				for (var i:int = 0; i < len; i++)
				{
					var child:Object = layer.getChildAt(i);
					if ( child.name == name )
					{
						count++;
					}
					if (child is DisplayObjectContainer && !( child is Loader ) )
					{
						count += countDuplicates( name, child as DisplayObjectContainer );
					}
				}
			}
			return count;
		}
		
		/**
		 * Finds a child by id recursively. 
		 * 
		 * @param name  The child's name.
		 * @param layer The layer to search.
		 * 
		 * @return  The child or null if not found.
		 */
		public static function byId( name:String, layer:DisplayObjectContainer ):DisplayObject
		{
			var result:DisplayObject;
			if ( name && layer )
			{
				var len:int = layer.numChildren;
				for (var i:int = 0; i < len && result == null; i++)
				{
					var child:Object = layer.getChildAt(i);
					if ( child.hasOwnProperty("id") && child.id == name )
					{
						result = child as DisplayObject;
					}
					else if (child is DisplayObjectContainer && !( child is Loader ) )
					{
						result = byId(name, child as DisplayObjectContainer);
					}
				}
			}
			return result;
		}
		
	}
}