package dragonbones {

	import citrus.core.starling.StarlingCitrusEngine;

	[SWF(frameRate="60")]

	/**
	* @author Aymeric
	*/
	public class Main extends StarlingCitrusEngine {

		public function Main() {

			setUpStarling(true);

			state = new DragonBonesGameState();
		}
	}
}