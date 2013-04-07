package
{
	
	import citrus.core.starling.StarlingCitrusEngine;
	
	//0xDEF2FC
	
	[SWF(frameRate="60", width="1280", height="720", backgroundColor="0xb6dffc")]
	public class MickeyRun extends StarlingCitrusEngine
	{
		private var _context:GameContext = new GameContext();
		public function MickeyRun()
		{
			setUpStarling(true);
			
			state = new TinyWingsGameState( _context );
		}
	}
}