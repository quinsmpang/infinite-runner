package
{
	import flash.geom.Point;
	
	import common.interfaces.ILog;
	import common.util.SubscribableHashtable;
	import common.util.TraceLog;
	
	import org.osflash.signals.Signal;
	
	import steamboat.data.AssetLoader;
	import steamboat.data.AssetManager;
	import steamboat.data.LoaderQueue;
	import steamboat.data.metadata.MetaData;

	public class GameContext
	{		
		public var viewMaster:ViewMaster;
		
		public var gameEndedSig:Signal;
		public var hasGameEnded:Boolean = false;
		
		public var heroMinSpeed:int = 180;
		public var heroMaxSpeed:int = 200;
		
		public var numCratesHit:int = 1;
		
		public var viewCamPos:Point;
		public var viewCamPosX:int = 0;
		public var viewCamLensWidth:int = 0;
		private var screenHalfX:int = 0;
		
		public var minY:int = -1200;
		
		public var currentLevel:String = "lev_01";
		public var maxLevel:int = 1;
		
		public var log:ILog;
		
		public var loaderQueue:LoaderQueue;
		public var assetMgr:AssetManager;
		public var assetLoader:AssetLoader;
		public var gameState:SubscribableHashtable;
		
		private static var _instance:GameContext;
		
		public function GameContext()
		{
			gameEndedSig = new Signal();
			_instance = this;
			
			log = new TraceLog();
			
			new MetaData( log );
			
			assetMgr = new AssetManager( this );
			assetLoader = new AssetLoader( log, false );
			
			loaderQueue = new LoaderQueue( this );
			
			gameState = new SubscribableHashtable();
		}
		
		public function initNewLevel():void
		{
			viewCamPosX = 0;
			viewCamLensWidth = 0;
			hasGameEnded = false;
			gameEndedSig.removeAll();
		}
		
		public function setViewCamLensWidth( w:int ):void
		{
			viewCamLensWidth = w;
			screenHalfX = viewCamLensWidth / 2;
		}
		
		public function gameEnded():void
		{
			gameEndedSig.dispatch();
			gameEndedSig.removeAll();
		}
		
		private var gameDuration:int = 0;
		public function getAndIncGameDuration():int 
		{
			gameDuration += 5000;
			heroMaxSpeed += 100;
			if ( gameDuration > 120000 ) gameDuration = 60000;
			return gameDuration;
		}
		
		private var gameDistance:int = 0;
		public function getAndIncGameDistance():int 
		{
			gameDistance = 2600;
			heroMaxSpeed += 5;
			if ( gameDistance > 600000 ) gameDistance = 600000;
			return gameDistance;
		}
		
		public function onCrateHit():void 
		{
			numCratesHit--;
			if ( numCratesHit <= 0 ) {
				gameEnded();
			}
		}
		
		public function isTouchSideRight( touchPoint:Point ):Boolean
		{
			if ( touchPoint.x > screenHalfX ) {
				return true;
			} else {
				return false;
			}
		}
		
		public static function getInstance():GameContext
		{
			return _instance;
		}
		
		public function locToPoint( loc:String, mult:int=1 ):Point
		{
			if ( loc )
			{
				var idx:int = loc.indexOf( "|" );
				if ( idx != -1 )
				{
					try
					{
						return new Point( mult * parseInt( loc.substring( 0, idx ) ), mult * parseInt( loc.substr( idx + 1 ) ) );
					}
					catch( err:Error )
					{}
				}
			}
			return new Point( 0, 0 );
		}
		
	}
}