package
{
	import org.osflash.signals.Signal;

	public class GameContext
	{		
		public var gameEndedSig:Signal;
		public var hasGameEnded:Boolean = false;
		
		public var heroMaxSpeed:int = 300;
		
		public var numCratesHit:int = 1;
		
		public function GameContext()
		{
			gameEndedSig = new Signal();
		}
		
		public function initNewLevel():void
		{
			hasGameEnded = false;
			gameEndedSig.removeAll();
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
		
		private var gameDistance:int = 10000;
		public function getAndIncGameDistance():int 
		{
			gameDistance += 5000;
			heroMaxSpeed += 5;
			if ( gameDistance > 60000 ) gameDistance = 60000;
			return gameDistance;
		}
		
		public function onCrateHit():void 
		{
			numCratesHit--;
			if ( numCratesHit <= 0 ) {
				gameEnded();
			}
		}
	}
}