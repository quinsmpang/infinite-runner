package
{
	
	import citrus.core.starling.StarlingCitrusEngine;
	
	//0xDEF2FC
	
	[SWF(frameRate="60", width="960", height="640", backgroundColor="0xe7f0f4")]
	public class MickeyRun extends StarlingCitrusEngine
	{
		public function MickeyRun()
		{
			setUpStarling(true);
			
			state = new TinyWingsGameState();
		}
	}
}