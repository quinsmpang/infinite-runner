/*
* Playdom, Inc. (c)2013 All Rights Reserved
*/
package steamboat.data.metadata
{
	import flash.utils.Dictionary;

	public class SheetData
	{
		protected var _dic:Dictionary = new Dictionary();
		
		public function SheetData()
		{
		}
		
		public function getItems():Array
		{
			var a:Array = [];
			var c:uint = 0;
			for each (var kid:Object in _dic)
			{
				a[c] = kid;
				c++;
			}
			return a;
		}
		
		public function getRowData(uid:String):RowData
		{
			var item:RowData = _dic[uid];
			if (item === null)
			{
				item = new RowData();
				item.uid = uid;
				_dic[uid] = item;
			}
			return item;
		}
		
		public function findValue( columnId:String, value:Object ):RowData
		{
			for each ( var rowData:RowData in _dic )
			{
				if ( rowData.getObject( columnId ) == value )
				{
					return rowData;
				}
			}
			return null;
		}
		
		public function getInt( rowId:String, columnId:String="value", def:int=0 ):int
		{
			return getRowData( rowId ).getInt( columnId, def );
		}
		
		public function getArray( rowId:String, columnId:String="value", def:Array=null ):Array
		{
			return getRowData( rowId ).getArray( columnId, def );
		}
		
		public function getString( rowId:String, columnId:String="value", def:String=null ):String
		{
			return getRowData( rowId ).getString( columnId, def );
		}
		
		public function getNumber( rowId:String, columnId:String="value", def:Number=0 ):Number
		{
			return getRowData( rowId ).getNumber( columnId, def );
		}
		
		public function getObject( rowId:String, columnId:String="value", def:Object=null ):Object
		{
			return getRowData( rowId ).getObject( columnId, def );
		}
		
		public function getBoolean( rowId:String, columnId:String="value", def:Boolean=false ):Boolean
		{
			return getRowData( rowId ).getBoolean( columnId, def );
		}
		
		public function hasTag( rowId:String, tag:String ):Boolean
		{
			return getRowData( rowId ).hasTag( tag );
		}
		
	}
}