package
{
	
	import citrus.core.starling.StarlingCitrusEngine;
	
	//0xDEF2FC
	
	[SWF(frameRate="60", width="1280", height="800", backgroundColor="0x000000")]
	public class MickeyRun extends StarlingCitrusEngine
	{
		public function MickeyRun()
		{
			setUpStarling(true);
			
			state = new TinyWingsGameState();
		}
	}
}