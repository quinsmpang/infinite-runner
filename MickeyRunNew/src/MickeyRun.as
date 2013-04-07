package
{
	
	import citrus.core.starling.StarlingCitrusEngine;
	
//	[SWF(frameRate="60", backgroundColor="0xb6dffc")]
	[SWF(frameRate="60", width="1280", height="720", backgroundColor="0xb6dffc")]
	public class MickeyRun extends StarlingCitrusEngine
	{
		private var _context:GameContext = new GameContext();
		public function MickeyRun()
		{
			setUpStarling(true);
			
			state = new GameState( _context );
		}
	}
}