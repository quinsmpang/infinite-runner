package
{
	
	import citrus.core.starling.StarlingCitrusEngine;
	

	
	[SWF(frameRate="60", width="1024", height="768", backgroundColor="0xDEF2FC")]
	public class MickeyRun extends StarlingCitrusEngine
	{
		public function MickeyRun()
		{
			setUpStarling(true);
			
			state = new TinyWingsGameState();
		}
	}
}