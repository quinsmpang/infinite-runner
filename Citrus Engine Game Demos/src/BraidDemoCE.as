package {
	
	import flash.geom.Rectangle;
	
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.utils.Mobile;
	
	import games.braid.BraidDemo;
	
	import starling.core.Starling;
	
	[SWF(frameRate="60")]
	
	public class BraidDemoCE extends StarlingCitrusEngine
	{
		
		public function BraidDemoCE():void
		{
			if (Mobile.isAndroid()) {
				
				Starling.handleLostContext = true;
				Starling.multitouchEnabled = true;
				
				setUpStarling(true, 1, new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight));
			} else
				setUpStarling(true, 1);
			
			state = new BraidDemo();
		}
		
	}
	
}

