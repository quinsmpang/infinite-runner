package
{
	import citrus.core.starling.StarlingCitrusEngine;
	
	import games.napecrates.NapeStarlingGameState;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class NapeCrates extends StarlingCitrusEngine
	{
		public function NapeCrates()
		{
			//super();
			
			setUpStarling(true);
			
			state = new NapeStarlingGameState();
		}
	}
}