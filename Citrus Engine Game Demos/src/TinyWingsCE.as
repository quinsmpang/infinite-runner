package {
	
	import citrus.core.starling.StarlingCitrusEngine;
	
	import games.tinywings.TinyWingsGameState;
	
	[SWF(frameRate="60", width="960", height="640", backgroundColor="0xffffff")]
	
	/**
	 * @author Aymeric
	 */
	public class TinyWingsCE extends StarlingCitrusEngine {
		
		public function TinyWingsCE() {
			
			setUpStarling(true);
			
			state = new TinyWingsGameState();
		}
	}
}

