package games.tinywings {

	import citrus.core.starling.StarlingCitrusEngine;

	import games.tinywings.box2d.TinyWingsGameState;
	
	[SWF(frameRate="60")]

	/**
	 * @author Aymeric
	 */
	public class Main extends StarlingCitrusEngine {

		public function Main() {
			
			setUpStarling(true);
			
			// There is a demo for nape and box2d. You just need to change the package!
			
			state = new TinyWingsGameState();
		}
	}
}
