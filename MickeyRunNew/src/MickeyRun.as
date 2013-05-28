package
{
	
	import com.playdom.common.util.JSONLite;
	
	import flash.filesystem.File;
	
	import citrus.core.starling.StarlingCitrusEngine;
	
	import starling.core.Starling;
	
	import steamboat.data.AssetLoader;
	import steamboat.data.metadata.MetaData;
	
//	[SWF(frameRate="60", backgroundColor="0xb6dffc")]
//	[SWF(frameRate="60", width="960", height="640", backgroundColor="0x000000")]
	[SWF(frameRate="60", width="1280", height="760", backgroundColor="0xffffff")]
	public class MickeyRun extends StarlingCitrusEngine
	{
		private var _context:GameContext = new GameContext();
		public function MickeyRun()
		{
			Starling.multitouchEnabled = true;
			Starling.handleLostContext = true;
			setUpStarling( true );
			
			
			_context.gameState.addKeyListener( "patch.file", handleFileLoaded );
//			var f:String = File.applicationDirectory.url;
//			var g:String = File.applicationStorageDirectory.url;
			var uriToLoad:String = "data.json"; 
			_context.loaderQueue.loadItem( "patch.file", uriToLoad, "patches", AssetLoader.TYPE_TEXT, true );
		}
		
		private function handleFileLoaded( key:String, value:String ) : void
		{
			MetaData.instance.parseMetaDataObject( JSONLite.decode( value ) );
			state = new GameState( _context );
		}
	}
}