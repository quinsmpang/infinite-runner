package
{
	import citrus.core.starling.StarlingCitrusEngine;
	
	import games.hungryhero.com.hsharma.hungryHero.screens.InGame;
	
	import starling.events.Event;
	
	/**
	 * SWF meta data defined for iPad 1 & 2 in landscape mode. 
	 */	
	[SWF(frameRate="60", width="1024", height="768", backgroundColor="0x000000")]
	
	public class HungryHeroCE extends StarlingCitrusEngine
	{
		public function HungryHeroCE()
		{
			super();
			
			setUpStarling(true);
		}
		
		override protected function _context3DCreated(evt:Event):void {
			
			super._context3DCreated(evt);
			
			state = new InGame();
			
			//_starling.stage.addChild(new Game());
		}
	}
}