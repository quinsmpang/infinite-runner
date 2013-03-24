package
{
	import org.osflash.signals.Signal;

	public class GameContext
	{		
		public var gameEndedSig:Signal;
		public var hasGameEnded:Boolean = false;
		
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
		}
		
		private var gameDuration:int = 30000;
		public function getAndIncGameDuration():int 
		{
			gameDuration += 15000;
			if ( gameDuration > 120000 ) gameDuration = 60000;
			return gameDuration;
		}
	}
}