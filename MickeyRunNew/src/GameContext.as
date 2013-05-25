package
{
	import com.playdom.common.interfaces.ILog;
	import com.playdom.common.util.EnterFrameDispatcher;
	import com.playdom.common.util.SubscribableHashtable;
	import com.playdom.common.util.TraceLog;
	import com.playdom.gas.AnimControl;
	import com.playdom.gas.AnimList;
	import com.playdom.gas.anims.TaskAnim;
	
	import flash.geom.Point;
	
	import citrus.core.CitrusEngine;
	
	import objects.Pluto;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Button;
	
	import steamboat.data.AssetLoader;
	import steamboat.data.AssetManager;
	import steamboat.data.LoaderQueue;
	import steamboat.data.metadata.MetaData;
	
	import views.GameHUD;

	public class GameContext
	{		
		public var viewMaster:ViewMaster;
		
		public var gameEndedSig:Signal;
		public var hasGameEnded:Boolean = false;
		
		public var heroMinSpeed:int = 100;
		public var heroMaxSpeed:int = 150;
		
		public var numCratesHit:int = 1;
		
		public var viewCamPos:Point;
		public var viewCamLeftX:int = 0;
		public var viewCamLensWidth:int = 0;
		public var viewCamRightX:int = 0;
		private var screenHalfX:int = 0;
		
		public var minY:int = 0;
		public var maxY:int;
		
		public var currentLevel:String = "lev_02"; // starting level
		public var currentLevelNum:int; // starting level
		
		public var log:ILog;
		
		public var loaderQueue:LoaderQueue;
		public var assetMgr:AssetManager;
		public var assetLoader:AssetLoader;
		public var gameState:SubscribableHashtable;
		
		public var _mickey:MickeyHero;
		public var _pluto:Pluto;
		
		public var startButton:Button;
		public var pauseButton:Button;
		
		public var levelButton1:Button;
		public var levelButton2:Button;
		public var levelButton3:Button;
		
		public var levelNumStars:Array = [];
		
		public var hud:GameHUD;
		
		public const TEXTURE_SCALE:Number = 0.8;
		
		public const CAM_ZOOM:Number = 1.0;
		public const CAM_ZOOM_MULT:Number = ( 1 - CAM_ZOOM ) + 0.1;
		
		public var groundLevel:int = 0;
		
		public var animControl:AnimControl;
		public var enterFrameDispatcher:EnterFrameDispatcher;
		
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
			viewCamLeftX = 0;
			viewCamLensWidth = 0;
			hasGameEnded = false;
			gameEndedSig.removeAll();
			
			viewMaster.init();
		}
		
		public function pauseGame():void
		{
			CitrusEngine.getInstance().playing = false;
			pauseButton.visible = false;
			startButton.visible = true;
		}
		
		public function endGame():void
		{
			viewMaster._mobileInput._enabled = false;
			_mickey._isMoving = false;
			_pluto._isMoving = false;
			
			var alist:AnimList = animControl.attachAnimList();
			var task:TaskAnim = TaskAnim.make( alist, 1500 );
			task.addTask( endGameHelper );
		}
		
		private function endGameHelper():void
		{
			var numStars:int = levelNumStars[ currentLevelNum ];
			if ( _mickey.numCoinsCollected > numStars ) {
				levelNumStars[ currentLevelNum ] = numStars = _mickey.numCoinsCollected;
			}
			
			viewMaster.setStars( currentLevelNum, numStars );
			
			gameEndedSig.dispatch();
			gameEndedSig.removeAll();
			CitrusEngine.getInstance().playing = false;
			pauseButton.visible = false;
			
			levelButton1.visible = levelButton2.visible = levelButton3.visible = true;
			viewMaster.showStars( true );
		}
		
		public function setViewCamLensWidth( w:int ):void
		{
			viewCamLensWidth = w;
			screenHalfX = viewCamLensWidth / 2;
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
//				endGame();
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