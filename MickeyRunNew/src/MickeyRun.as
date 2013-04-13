package
{
	
	import citrus.core.starling.StarlingCitrusEngine;
	
	import starling.core.Starling;
	
//	[SWF(frameRate="60", backgroundColor="0xb6dffc")]
	[SWF(frameRate="60", width="1280", height="760", backgroundColor="0xb6dffc")]
	public class MickeyRun extends StarlingCitrusEngine
	{
		private var _context:GameContext = new GameContext();
		public function MickeyRun()
		{
			Starling.multitouchEnabled = true;
			Starling.handleLostContext = true;
			setUpStarling(true);
			
			state = new GameState( _context );
		}
	}
}