package
{
	
	import citrus.core.starling.StarlingCitrusEngine;
	

	
	[SWF(frameRate="60", width="960", height="640", backgroundColor="0xafe1f2")]
	public class MickeyRun extends StarlingCitrusEngine
	{
		public function MickeyRun()
		{
			setUpStarling(true);
			
			state = new TinyWingsGameState();
		}
	}
}