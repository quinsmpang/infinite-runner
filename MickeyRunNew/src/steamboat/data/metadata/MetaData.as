/*
* Playdom, Inc. (c)2013 All Rights Reserved
*/
package steamboat.data.metadata
{
	import flash.utils.getTimer;
	
	import com.playdom.common.interfaces.ILog;

	public class MetaData
	{
		public static var instance:MetaData;
		
		private var _result:Object = {};
		private var _log:ILog;
		private var _hashDefs:Object = [];
		
		/**
		 * Constructor. 
		 */
		public function MetaData( log:ILog )
		{
			instance = this;
			_log = log;
		}
		
		/**
		 * Pareses a meta data object containing definitions to be stored by unique ID.  
		 * The sheet name determines the type of definitions stored on each sheet.
		 *  
		 * @param dataObj The data object to parse.
		 */
		public function parseMetaDataObject( dataObj:Object ):void
		{
			var startTime:uint = getTimer();
			var bucket:Array;
			var factory:SheetData;
			
			dataObj = dataObj.content.objects;
			
			// parse each sheet
			for (var sheetId:String in dataObj) 
			{
				var sheet:Object = dataObj[ sheetId ];
				
				// initialize the sheet
				bucket = _initSheet( sheetId );
				
				// find the codec for this sheet
				factory = getSheetData( sheetId.toLowerCase() );
				
				// parse each item in the sheet
				for (var idx:String in sheet)
				{
					var item:Object = sheet[ idx ];
					var uid:String = item.uid ? item.uid : item._id;
					var o:Object = factory.getRowData(uid);
					
					// parse each header associated with the item
					for (var header:String in item)
					{
						_storeValue( header.toLowerCase(), o, item[ header ] );
					}
				}
				bucket.push( o );
			}
			var endTime:uint = getTimer();
			_log.info( ".parseMetaDataObject: parsed in " + ( endTime - startTime ) + " ms", this );
		}
		
		/**
		 * Initializes a sheet specified by a unique name.
		 *   
		 * @param sheetId  The sheet name.
		 * 
		 * @return           The newly created or exisiting sheet object. 
		 */
		private function _initSheet( sheetId:String ):Array
		{
			var bucket:Array;
			
//			robsTrace( "sheet = " + sheetId );
			
			// initialize the sheet
			if (_result[sheetId] == null)
			{
				bucket = [];
				_result[sheetId] = bucket;	
			}
			else
			{
				bucket = _result[sheetId];
			}
			
			return bucket;
		}
		
		/**
		 * Stores a key-value pair based on a header name and data storage object.
		 *  
		 * @param header The header name.
		 * @param o      The data storage object.
		 * @param value  The value to be sotred.
		 */
		private function _storeValue( header:String, dataObj:Object, value:Object ):void
		{
			if (header.indexOf('--') != 0)
			{
//				robsTrace( "    header = " + header );
				
				var isListColumn:Boolean = (header.indexOf("[") == 0)
				if (isListColumn)
				{
					header = header.slice(1,-1);
				}
				else
				{
					isListColumn = value is Array;	
				}
				
				var link:SheetData = null;
				
				// check for @ notation that identifies a codec to dereference the value 
				if (header.indexOf("@") !== -1)
				{
					var ref:String = header.split("@")[1];
					header = header.split("@")[0];
					link = getSheetData( ref.toLowerCase() ); 
				}
				if ( value is String )
				{
					var idx:int = value.indexOf( "@" );
					if ( idx != -1 )
					{
						if ( idx > 1 && value.charAt( idx - 1 ) != "/" )
						{
							ref = value.substr( idx + 1 );
							value = value.substring( 0, idx );
							link = getSheetData( ref.toLowerCase() );
						}
					}
				}
				
				if ( header == "default" )	// default cannot be used as an object property, so it is changed here
				{
					header = "startingValue";
//					_log.warning( "._storeValue: header name cannot be 'default'", this );
				}
				
				// check for invalid property
				if ( dataObj is RowData )
				{
					dataObj = dataObj.values;	// point at the generic object containing the hash data
				}
				else if ( !dataObj.hasOwnProperty( header ) )
				{
//					robsTrace( "      (no property to set)" );
					return;
				}
				
				// check for string header
				if (isListColumn)
				{	// found a list - resolve values if there is a codec
					if (value == "" ||  value == null)
					{
						dataObj[header] =  [];
					}
					else if ( value is Array )
					{
						dataObj[header] =  value;
					}
					else
					{
						dataObj[header] =  value.split(' ');
					}
//					robsTrace( "      list = " + value );
					
					if (link != null)
					{
						_resolveList( dataObj[header], link )
					}
				}
				else if (value != "" && value != null)
				{	// normal value
					if (link != null)
					{	// resolve value if there is a codec
//						robsTrace( "      value = [" + value + "]" );
						dataObj[header] = link.getRowData(value as String);
					}
					else
					{
						dataObj[header] = value;
//						robsTrace( "      value = " + value );
					}
				}
//				else
//				{
//					robsTrace( "      value = " + value );
//				}
			}
		}
		
		/**
		 * Resolves a list of values using a codec.
		 *  
		 * @param list  The list of values.
		 * @param codec The codec.
		 */
		private function _resolveList(list:Array, codec:SheetData):void
		{
			var len:uint = list.length;
			for (var i:uint = 0; i < len; i++)
			{
				list[ i ] = codec.getRowData( list[i] );
			}
		}
		
		public static function getSheetData( sheetId:String ):SheetData
		{
			return instance.getSheetData( sheetId );
		}
		
		public static function getRowData( sheetId:String, rowId:String ):RowData
		{
			return instance.getRowData( sheetId, rowId );
		}
		
		public static function getInt( sheetId:String, rowId:String, columnId:String="value", def:int=0 ):int
		{
			return instance.getRowData( sheetId, rowId ).getInt( columnId, def );
		}
		
		public static function getNumber( sheetId:String, rowId:String, columnId:String="value", def:Number=0 ):Number
		{
			return instance.getRowData( sheetId, rowId ).getNumber( columnId, def );
		}
		
		public static function getObject( sheetId:String, rowId:String, columnId:String="value", def:Object=null ):Object
		{
			return instance.getRowData( sheetId, rowId ).getObject( columnId, def );
		}
		
		public static function getBoolean( sheetId:String, rowId:String, columnId:String="value", def:Boolean=false ):Boolean
		{
			return instance.getRowData( sheetId, rowId ).getBoolean( columnId, def );
		}
		
		public static function getString( sheetId:String, rowId:String, columnId:String="value", def:String=null ):String
		{
			return instance.getRowData( sheetId, rowId ).getString( columnId, def );
		}
		
		public static function getArray( sheetId:String, rowId:String, columnId:String="value", def:Array=null ):Array
		{
			return instance.getRowData( sheetId, rowId ).getArray( columnId, def );
		}
		
		public static function hasTag( sheetId:String, rowId:String, tag:String ):Boolean
		{
			return instance.getRowData( sheetId, rowId ).hasTag( sheetId );
		}
		
		public static function getConstantsString( rowId:String, def:String=null ):String
		{
			return getString( "constants", rowId, "value", def );
		}
		
		public static function getConstantsNumber( rowId:String, def:Number=0 ):Number
		{
			return getNumber( "constants", rowId, "value", def );
		}
		
		public static function getConstantsBoolean( rowId:String, def:Boolean=false ):Boolean
		{
			return getBoolean( "constants", rowId, "value", def );
		}
		
		/**
		 * Fetches a definition collection based on a sheet name.
		 *  
		 * @param sheetId The sheet name.
		 * 
		 * @return          The definition collection or null if not found.
		 */
		public function getSheetData( sheetId:String ):SheetData
		{
			sheetId = sheetId.toLowerCase();
			if ( !_hashDefs.hasOwnProperty( sheetId ) )
			{
				_hashDefs[ sheetId ] = new SheetData();
			}
			return _hashDefs[ sheetId ];
		}
		
		public function getRowData( sheetId:String, rowId:String ):RowData
		{
			return getSheetData( sheetId ).getRowData( rowId );
		}
		
	}
}