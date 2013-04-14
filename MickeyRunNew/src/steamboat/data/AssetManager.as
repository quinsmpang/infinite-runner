package steamboat.data
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	/**
	 * Manages the asset bundles based on maximum level played.
	 *  
	 * @author rharris
	 */
	public class AssetManager
	{
		private var _context:GameContext;
		private var _assets:Array;
		private var _assetLevels:Array;
		private var _assetTotals:Array;
		private var _loadCount:int;
		private var _testHash:Dictionary = new Dictionary();
		
		public function AssetManager( context:GameContext )
		{
			_context = context;
//			_context.progressListener = handleItemProgress;
		}
		
		public static var ignoreMissing:Boolean = false;
		
		public function logImage( key:String, bmd:BitmapData ):void
		{
			var test:String = _testHash[ key ];
			if ( !test )
			{
				if ( bmd )
				{
					_testHash[ key ] = "found ";
//					_context.log.info( ".logImage: " + _testHash[ key ] + key, this );
				}
				else
				{
					_testHash[ key ] = "MISSING ";
					if ( !ignoreMissing )
					{
						_context.log.warning( ".logImage: " + _testHash[ key ] + key, this );
					}
				}
			}
			
		}
		

		
		public function loadItem( key:String, url:String, type:String, preloadId:String, listener:Function ):Object
		{
			var item:Object;
			switch ( type )
			{
				case AssetLoader.TYPE_IMAGE:
					item = prepItem( _context.assetLoader.loadImage( key, url, listener ), preloadId );
					break;
				case AssetLoader.TYPE_SOUND:
					item = prepItem( _context.assetLoader.loadSound( key, url, listener ), preloadId );
					break;
				case AssetLoader.TYPE_SWF:
					item = prepItem( _context.assetLoader.loadSWF( key, url, listener ), preloadId );
					break;
				case AssetLoader.TYPE_XML:
					item = prepItem( _context.assetLoader.loadText( key, url, listener ), preloadId );
					break;
				case AssetLoader.TYPE_BINARY:
					item = prepItem( _context.assetLoader.loadBinary( key, url, listener ), preloadId );
					break;
				case AssetLoader.TYPE_TEXT:
					item = prepItem( _context.assetLoader.loadText( key, url, listener ), preloadId );
					break;
			}
			return item;
		}
		
		public function putItem( item:Object ):void
		{
			switch (item.type) 
			{
				case AssetLoader.TYPE_IMAGE:
//					_context.assetHash.putBitmapData( item.key, item.data );
					notifyLoaded( item );
					break;
				case AssetLoader.TYPE_SOUND:
//					_context.assetHash.putSound( item.key, item.data );
					notifyLoaded( item );
					break;
				case AssetLoader.TYPE_SWF:
//					_context.gameState.setObject( item.key, item.data );
//					if ( item.key.indexOf( "assetSwf" ) == 0 )
//					{
//						processSwf( item.key, item.data );
//					}
					notifyLoaded( item );
					break;
				case AssetLoader.TYPE_XML:
					_context.gameState.setObject( item.key, item.data );
					notifyLoaded( item );
					break;
				case AssetLoader.TYPE_BINARY:
					_context.gameState.setObject( item.key, item.data );
					notifyLoaded( item );
					break;
				case AssetLoader.TYPE_TEXT:
					_context.gameState.setObject( item.key, item.data );
					notifyLoaded( item );
					break;
			}
		}
		
		private function prepItem( item:Object, preloadId:String ):Object
		{
			if ( preloadId )
			{
				item.preloadId = preloadId;
			}
			return item;
		}
		
		private function notifyLoaded( item:Object ):void
		{
			if ( item.preloadId )
			{
//				_context.dispatcher.dispatchKeyEvent( "preload.inc", item.preloadId );
			}
		}

	}
}