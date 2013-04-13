package
{
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;

	public class GameContext
	{		
		public var viewMaster:ViewMaster;
		
		public var gameEndedSig:Signal;
		public var hasGameEnded:Boolean = false;
		
		public var heroMinSpeed:int = 180;
		public var heroMaxSpeed:int = 200;
		
		public var numCratesHit:int = 1;
		
		public var viewCamPosX:int = 0;
		public var viewCamLensWidth:int = 0;
		private var screenHalfX:int = 0;
		
		public var currentLevel:int = 1;
		public var maxLevel:int = 1;
		
		private static var _instance:GameContext;
		
		public function GameContext()
		{
			gameEndedSig = new Signal();
			_instance = this;
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
	}
}